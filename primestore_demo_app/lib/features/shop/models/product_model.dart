class ProductImageModel {
  final int id;
  final String imageUrl;
  final int sortOrder;

  ProductImageModel({required this.id, required this.imageUrl, required this.sortOrder});

  String? get displayUrl => imageUrl.isEmpty ? null : imageUrl;

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
  final double? salePrice;
  final int discountPercent;
  final int stock;

  ProductVariantModel({
    required this.id,
    required this.color,
    required this.size,
    required this.price,
    required this.salePrice,
    required this.discountPercent,
    required this.stock,
  });

  double get effectivePrice => salePrice ?? price;

  /// "Red · M", or "Standard" when the variant has no colour or size.
  String get label {
    final parts = [if (color.isNotEmpty) color, if (size.isNotEmpty) size];
    return parts.isEmpty ? 'Standard' : parts.join(' · ');
  }

  bool get isOnSale => salePrice != null && salePrice! < price;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'],
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      salePrice: json['sale_price'] == null
          ? null
          : double.tryParse(json['sale_price'].toString()),
      discountPercent: json['discount_percent'] ?? 0,
      stock: json['stock'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final int? categoryId;
  final int? brandId;
  final String name;
  final String description;
  final String categoryName;
  final bool isFeatured;
  final String brandName;
  final bool brandVerified;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    this.categoryId,
    this.brandId,
    required this.name,
    required this.description,
    this.categoryName = '',
    required this.isFeatured,
    required this.brandName,
    required this.brandVerified,
    required this.images,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: (json['category_id'] as num?)?.toInt(),
      brandId: (json['brand_id'] as num?)?.toInt(),
      name: json['name'],
      description: json['description'] ?? '',
      categoryName: json['category_name'] ?? '',
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
