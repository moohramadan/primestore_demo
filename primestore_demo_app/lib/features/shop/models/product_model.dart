import 'package:demo_project/utils/constants/api_constants.dart';

class ProductImageModel {
  final int id;
  final String imageUrl;
  final int sortOrder;

  ProductImageModel({required this.id, required this.imageUrl, required this.sortOrder});

  String? get displayUrl {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (!imageUrl.startsWith('products/')) return imageUrl;

    final baseUrl = ApiConstants.s3PublicBaseUrl.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    if (baseUrl.isEmpty) return null;

    final encodedKey = imageUrl
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');
    return '$baseUrl/$encodedKey';
  }

  bool get isNetworkImage {
    final url = displayUrl;
    return url != null &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'],
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'],
    );
  }
}

class ProductVariantModel {
  final int id;
  final String color;
  final String size;
  final double price;
  final int discountPercent;
  final int stock;

  ProductVariantModel({
    required this.id,
    required this.color,
    required this.size,
    required this.price,
    required this.discountPercent,
    required this.stock,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'],
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      discountPercent: json['discount_percent'] ?? 0,
      stock: json['stock'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String description;
  final bool isFeatured;
  final String brandName;
  final bool brandVerified;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isFeatured,
    required this.brandName,
    required this.brandVerified,
    required this.images,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      brandName: json['brand_name'] ?? '',
      brandVerified: json['brand_verified'] ?? false,
      images: (json['images'] as List).map((i) => ProductImageModel.fromJson(i)).toList(),
      variants: (json['variants'] as List).map((v) => ProductVariantModel.fromJson(v)).toList(),
    );
  }

  /// Convenience: the first variant, used for "top-level" price display
  ProductVariantModel? get defaultVariant => variants.isNotEmpty ? variants.first : null;

  /// Convenience: lowest sort_order image, used as the card thumbnail
  String? get mainImageUrl => images.isNotEmpty ? images.first.displayUrl : null;
}
