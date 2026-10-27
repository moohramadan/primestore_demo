import 'dart:convert';
import 'dart:typed_data';

import 'package:demo_project/data/repositories/authenticated_http_client.dart';
import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final AuthenticatedHttpClient _authenticatedClient =
      AuthenticatedHttpClient();

  Future<List<ProductModel>> fetchSellerProducts() async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.get(
        Uri.parse('${ApiConstants.baseUrl}/seller/products'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load your products');
    }

    return _parseProducts(response);
  }

  Future<List<ProductOption>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load categories');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('The server returned invalid categories.');
    }
    return decoded
        .map((item) {
          if (item is! Map<String, dynamic> ||
              item['id'] is! num ||
              item['name'] is! String) {
            throw const FormatException(
              'The server returned invalid categories.',
            );
          }
          return ProductOption(
            id: (item['id'] as num).toInt(),
            name: item['name'] as String,
            icon: item['icon'] is String ? item['icon'] as String : '',
          );
        })
        .where((category) => category.name.toLowerCase() != 'all')
        .toList();
  }

  Future<List<ProductModel>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/category/$categoryId'),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load products for category');
    }

    return _parseProducts(response);
  }

  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/featured'),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load featured products');
    }
    return _parseProducts(response);
  }

  Future<List<ProductOption>> fetchBrands() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/brands'),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load brands');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('The server returned invalid brands.');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic> ||
          item['id'] is! num ||
          item['name'] is! String) {
        throw const FormatException('The server returned invalid brands.');
      }
      return ProductOption(
        id: (item['id'] as num).toInt(),
        name: item['name'] as String,
      );
    }).toList();
  }

  Future<List<String>> uploadProductImages(
    List<Uint8List> images, {
    List<String> existingPaths = const [],
    void Function(List<String> paths)? onPathsUpdated,
  }) async {
    if (images.isEmpty || images.length > 5) {
      throw ArgumentError('Select between 1 and 5 product images.');
    }
    if (existingPaths.length > images.length) {
      throw ArgumentError('Uploaded image paths do not match selected images.');
    }

    final files = images.skip(existingPaths.length).map((bytes) {
      final contentType = _imageContentType(bytes);
      if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
        throw ArgumentError('Each image must be between 1 byte and 5 MB.');
      }
      return {'content_type': contentType, 'size': bytes.length};
    }).toList();

    var uploads = const <dynamic>[];
    if (files.isNotEmpty) {
      final response = await _authenticatedClient.send(
        (accessToken) => http.post(
          Uri.parse('${ApiConstants.baseUrl}/seller/products/upload-urls'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'files': files}),
        ),
      );
      if (response.statusCode != 200) {
        throw _responseError(response, 'Could not prepare image uploads');
      }

      final decoded = _decodeObject(
        response,
        'Could not prepare image uploads',
      );
      final responseUploads = decoded['uploads'];
      if (responseUploads is! List || responseUploads.length != files.length) {
        throw const FormatException(
          'The server returned invalid upload URLs.',
        );
      }
      uploads = responseUploads;
    }

    final paths = List<String>.of(existingPaths);
    for (var uploadIndex = 0; uploadIndex < uploads.length; uploadIndex++) {
      final imageIndex = paths.length;
      final upload = uploads[uploadIndex];
      if (upload is! Map<String, dynamic> ||
          upload['path'] is! String ||
          upload['upload_url'] is! String ||
          upload['headers'] is! Map<String, dynamic>) {
        throw const FormatException(
          'The server returned invalid upload details.',
        );
      }

      final headers = (upload['headers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
      final putResponse = await http.put(
        Uri.parse(upload['upload_url'] as String),
        headers: headers,
        body: images[imageIndex],
      );
      if (putResponse.statusCode < 200 || putResponse.statusCode >= 300) {
        throw Exception(
          'Image upload failed (${putResponse.statusCode}). Please try again.',
        );
      }
      paths.add(upload['path'] as String);
      onPathsUpdated?.call(List<String>.unmodifiable(paths));
    }
    return paths;
  }

  Future<void> deleteUnusedProductImage(String path) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.post(
        Uri.parse('${ApiConstants.baseUrl}/seller/products/upload-cleanup'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'path': path}),
      ),
    );
    // 409 means a saved product already uses this image, so it must be kept.
    // Either way there is nothing left to clean up.
    if (response.statusCode != 204 && response.statusCode != 409) {
      throw _responseError(response, 'Could not remove uploaded image');
    }
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.post(
        Uri.parse('${ApiConstants.baseUrl}/seller/products'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ),
    );
    if (response.statusCode != 201) {
      throw _responseError(response, 'Could not create product');
    }
  }

  Future<ProductModel> updateSellerProduct(
    int productId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.put(
        Uri.parse('${ApiConstants.baseUrl}/seller/products/$productId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not update product');
    }

    final decoded = _decodeObject(response, 'Could not update product');
    final product = decoded['product'];
    if (product is! Map<String, dynamic>) {
      throw const FormatException('The server returned an invalid product.');
    }
    return ProductModel.fromJson(product);
  }

  /// Decodes a response body holding a JSON list of products.
  List<ProductModel> _parseProducts(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('The server returned invalid products.');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('The server returned invalid products.');
      }
      return ProductModel.fromJson(item);
    }).toList();
  }

  String _imageContentType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    throw const FormatException('Choose a JPEG, PNG, or WebP image.');
  }

  Map<String, dynamic> _decodeObject(http.Response response, String fallback) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        '$fallback. The server returned an invalid response.',
      );
    }
    return decoded;
  }

  Exception _responseError(http.Response response, String fallback) {
    try {
      final decoded = _decodeObject(response, fallback);
      final message = decoded['error'];
      return Exception(
        message is String ? message : '$fallback (${response.statusCode}).',
      );
    } on FormatException {
      return Exception('$fallback (${response.statusCode}).');
    }
  }
}

class ProductOption {
  const ProductOption({required this.id, required this.name, this.icon = ''});

  final int id;
  final String name;

  /// Icon slug from the server (categories only), for example `headphone`.
  final String icon;
}
