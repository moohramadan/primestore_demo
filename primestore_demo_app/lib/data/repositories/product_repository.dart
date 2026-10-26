import 'dart:convert';
import 'dart:typed_data';

import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
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
          );
        })
        .where((category) => category.name.toLowerCase() != 'all')
        .toList();
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

  Future<List<String>> uploadProductImages(List<Uint8List> images) async {
    if (images.isEmpty || images.length > 5) {
      throw ArgumentError('Select between 1 and 5 product images.');
    }

    final accessToken = await _accessToken();
    final files = images.map((bytes) {
      final contentType = _imageContentType(bytes);
      if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
        throw ArgumentError('Each image must be between 1 byte and 5 MB.');
      }
      return {'content_type': contentType, 'size': bytes.length};
    }).toList();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/seller/products/upload-urls'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'files': files}),
    );
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not prepare image uploads');
    }

    final decoded = _decodeObject(response, 'Could not prepare image uploads');
    final uploads = decoded['uploads'];
    if (uploads is! List || uploads.length != images.length) {
      throw const FormatException('The server returned invalid upload URLs.');
    }

    final paths = <String>[];
    for (var i = 0; i < images.length; i++) {
      final upload = uploads[i];
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
        body: images[i],
      );
      if (putResponse.statusCode < 200 || putResponse.statusCode >= 300) {
        throw Exception(
          'Image upload failed (${putResponse.statusCode}). Check the bucket CORS and upload configuration.',
        );
      }
      paths.add(upload['path'] as String);
    }
    return paths;
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    final accessToken = await _accessToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/seller/products'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw _responseError(response, 'Could not create product');
    }
  }

  Future<String> _accessToken() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Please sign in before uploading product images.');
    }
    return token;
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
  const ProductOption({required this.id, required this.name});

  final int id;
  final String name;
}
