import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ---------------------------------------------------------------------
// Category -> sizing scheme
// ---------------------------------------------------------------------

/// Which sizing scheme a category uses. Add more schemes here if you ever
/// need a third kind (e.g. ring sizes, kids' ages, etc).
enum ProductSizeType { clothing, shoe, none }

/// Maps a category name (must match the strings used in your category
/// dropdown in product_info.dart) to its sizing scheme. Any category not
/// listed here falls back to [ProductSizeType.none] (color-only variants).
const Map<String, ProductSizeType> categorySizeTypeMap = {
  'Fashion': ProductSizeType.clothing,
  'Footwear': ProductSizeType.shoe,
};

/// The size chips shown for each sizing scheme.
const Map<ProductSizeType, List<String>> sizeOptionsByType = {
  ProductSizeType.clothing: ['S', 'M', 'L', 'XL', 'XXL'],
  ProductSizeType.shoe: [
    'EU 36', 'EU 37', 'EU 38', 'EU 39', 'EU 40',
    'EU 41', 'EU 42', 'EU 43', 'EU 44', 'EU 45', 'EU 46',
  ],
  ProductSizeType.none: [],
};

/// category_id / brand_id lookups, in the same order as the dropdown items
/// in product_info.dart. Replace these numbers with the real ids from your
/// `categories` / `brands` tables — everything else in this file works off
/// whatever ids these two maps return, so this is the only place to touch.
const Map<String, int> categoryIds = {
  'Sport': 1,
  'Electronics': 2,
  'Phones & Tablets': 3,
  'Home & Office': 4,
  'Fashion': 5,
  'Health & Beauty': 6,
  'Computing': 7,
  'Grocery': 8,
  'Garden & Outdoors': 9,
  'Automotive': 10,
  'Audio': 11,
  'Footwear': 12,
};

const Map<String, int> brandIds = {
  'Nike': 1,
  'Adidas': 2,
  'Puma': 3,
  'Apple': 4,
  'Samsung': 5,
  'Sony': 6,
  'JBL': 7,
  'Xiaomi': 8,
  'Huawei': 9,
  'HP': 10,
  'Dell': 11,
  'Lenovo': 12,
  'LG': 13,
  'Reebok': 14,
  'New Balance': 15,
  'Under Armour': 16,
  'Canon': 17,
  'Bose': 18,
};

// ---------------------------------------------------------------------
// Variant model
// ---------------------------------------------------------------------

/// One row that becomes a `product_variants` record on the backend.
/// `size` is null for categories with no sizing scheme.
class ProductVariantDraft {
  final String color;
  final String? size;
  final double price;
  final double discountPercent;
  final int stock;

  const ProductVariantDraft({
    required this.color,
    this.size,
    required this.price,
    required this.discountPercent,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'color': color,
        if (size != null) 'size': size,
        'price': price,
        'discount_percent': discountPercent,
        'stock': stock,
      };
}

// ---------------------------------------------------------------------
// Controller access
// ---------------------------------------------------------------------

/// Fetches the already-registered controller, or creates it the first time
/// it's needed. Safe to call from any widget's build method — unlike a bare
/// `Get.put(AddProductController())` in build(), this never resets state on
/// rebuild.
AddProductController get addProductController {
  if (Get.isRegistered<AddProductController>()) {
    return Get.find<AddProductController>();
  }
  return Get.put(AddProductController());
}

class AddProductController extends GetxController {
  // ---- product-level text fields ----
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  final RxString selectedCategory = 'Sport'.obs;
  final RxString selectedBrand = 'Nike'.obs;

  // ---- variant selection ----
  final RxList<String> selectedColors = <String>[].obs;
  final RxList<String> selectedSizes = <String>[].obs;

  /// key -> stock text field. Key is `color::size`, or just `color` when
  /// the current category has no sizing scheme.
  final RxMap<String, TextEditingController> stockControllers =
      <String, TextEditingController>{}.obs;

  ProductSizeType get sizeType =>
      categorySizeTypeMap[selectedCategory.value] ?? ProductSizeType.none;

  List<String> get availableSizes => sizeOptionsByType[sizeType]!;

  bool get needsSize => availableSizes.isNotEmpty;

  String _key(String color, String size) =>
      size.isEmpty ? color : '$color::$size';

  void setCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    // Drop any picked size that doesn't belong to the new scheme, e.g.
    // switching from Footwear to Fashion drops 'EU 42'.
    selectedSizes.removeWhere((s) => !availableSizes.contains(s));
    _syncStockControllers();
  }

  void setBrand(String brand) => selectedBrand.value = brand;

  void addColor(String color) {
    if (selectedColors.contains(color)) return;
    selectedColors.add(color);
    _syncStockControllers();
  }

  void removeColor(String color) {
    selectedColors.remove(color);
    _syncStockControllers();
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    _syncStockControllers();
  }

  /// Keeps [stockControllers] exactly in sync with the current
  /// colors x sizes combination (or just colors, when the category has no
  /// sizing scheme), adding new fields and disposing ones that no longer
  /// apply.
  void _syncStockControllers() {
    final validKeys = <String>{};

    if (!needsSize) {
      for (final color in selectedColors) {
        validKeys.add(_key(color, ''));
      }
    } else {
      for (final color in selectedColors) {
        for (final size in selectedSizes) {
          validKeys.add(_key(color, size));
        }
      }
    }

    final staleKeys =
        stockControllers.keys.where((k) => !validKeys.contains(k)).toList();
    for (final key in staleKeys) {
      stockControllers.remove(key)?.dispose();
    }

    for (final key in validKeys) {
      stockControllers.putIfAbsent(key, () => TextEditingController());
    }
  }

  List<ProductVariantDraft> buildVariants({
    required double price,
    required double discountPercent,
  }) {
    return stockControllers.entries.map((entry) {
      final parts = entry.key.split('::');
      final color = parts[0];
      final size = parts.length > 1 ? parts[1] : null;
      final stock = int.tryParse(entry.value.text.trim()) ?? 0;
      return ProductVariantDraft(
        color: color,
        size: size,
        price: price,
        discountPercent: discountPercent,
        stock: stock,
      );
    }).toList();
  }

  /// Full payload for the create-product endpoint. Shape mirrors the
  /// `products` / `product_variants` / `product_images` tables, so the
  /// backend side of this is just inserting it.
  Map<String, dynamic> buildProductPayload({
    required double price,
    required double discountPercent,
    List<String> imageUrls = const [],
  }) {
    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category_id': categoryIds[selectedCategory.value] ?? 0,
      'brand_id': brandIds[selectedBrand.value] ?? 0,
      'variants': buildVariants(price: price, discountPercent: discountPercent)
          .map((v) => v.toJson())
          .toList(),
      'images': [
        for (var i = 0; i < imageUrls.length; i++)
          {'image_url': imageUrls[i], 'sort_order': i},
      ],
    };
  }

  /// Replace this with your real API call (an http/dio POST to your Go
  /// backend's create-product route). It's a plain function field so
  /// wiring it up is a one-line change, not a rewrite of this controller:
  ///
  ///   addProductController.onSubmit = (payload) async {
  ///     await dio.post('/products', data: payload);
  ///   };
  Future<void> Function(Map<String, dynamic> payload) onSubmit =
      (payload) async => debugPrint('Product payload: $payload');

  Future<void> submitProduct({List<String> imageUrls = const []}) {
    final price = double.tryParse(originalPriceController.text.trim()) ?? 0;
    final salePrice = double.tryParse(salePriceController.text.trim());
    final discountPercent = (salePrice != null && salePrice > 0 && price > 0)
       ? ((price - salePrice) / price * 100).clamp(0, 100).toDouble()
        : 0.0;

    return onSubmit(buildProductPayload(
      price: price,
      discountPercent: discountPercent,
      imageUrls: imageUrls,
    ));
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    originalPriceController.dispose();
    salePriceController.dispose();
    for (final c in stockControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}