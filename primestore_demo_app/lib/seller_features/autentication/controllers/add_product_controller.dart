import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_project/data/repositories/product_repository.dart';

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

// ---------------------------------------------------------------------
// Variant model
// ---------------------------------------------------------------------

/// One row that becomes a `product_variants` record on the backend.
/// `color` is empty and `size` is null when the product has no variants.
class ProductVariantDraft {
  final String color;
  final String? size;
  final int stock;

  const ProductVariantDraft({
    required this.color,
    this.size,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'color': color,
        if (size != null) 'size': size,
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
  final ProductRepository _productRepository = ProductRepository();
  final RxList<ProductOption> categories = <ProductOption>[].obs;
  final RxList<ProductOption> brands = <ProductOption>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedBrandId = RxnInt(0);
  final RxString selectedCategoryName = ''.obs;
  final RxBool isLoadingProductOptions = true.obs;
  final RxnString productOptionsError = RxnString();

  // ---- product-level text fields ----
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  // ---- variant selection ----
  final RxList<String> selectedColors = <String>[].obs;
  final RxList<String> selectedSizes = <String>[].obs;

  /// key -> stock text field. Key is `color::size`, or just `color` when
  /// the current category has no sizing scheme.
  final RxMap<String, TextEditingController> stockControllers =
      <String, TextEditingController>{}.obs;

  ProductSizeType get sizeType =>
      categorySizeTypeMap[selectedCategoryName.value] ?? ProductSizeType.none;

  List<String> get availableSizes => sizeOptionsByType[sizeType]!;

  bool get needsSize => availableSizes.isNotEmpty;

  String _key(String color, String size) =>
      size.isEmpty ? color : '$color::$size';

  @override
  void onInit() {
    super.onInit();
    loadProductOptions();
  }

  Future<void> loadProductOptions() async {
    isLoadingProductOptions.value = true;
    productOptionsError.value = null;
    try {
      final results = await Future.wait<List<ProductOption>>([
        _productRepository.fetchCategories(),
        _productRepository.fetchBrands(),
      ]);
      categories.assignAll(results[0]);
      brands.assignAll(results[1]);
      if (categories.isEmpty) {
        throw StateError('Add at least one product category to the database.');
      }
      final selectedCategory = categories.where(
        (category) => category.id == selectedCategoryId.value,
      );
      if (selectedCategory.isEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
      selectedCategoryName.value = categories
          .firstWhere((category) => category.id == selectedCategoryId.value)
          .name;
    } catch (error) {
      productOptionsError.value = error.toString();
    } finally {
      isLoadingProductOptions.value = false;
    }
  }

  void setCategory(int categoryId) {
    final category = categories.firstWhere((item) => item.id == categoryId);
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = category.name;
    // Drop any picked size that doesn't belong to the new scheme, e.g.
    // switching from Footwear to Fashion drops 'EU 42'.
    selectedSizes.removeWhere((s) => !availableSizes.contains(s));
    _syncStockControllers();
  }

  void setBrand(int? brandId) => selectedBrandId.value = brandId;

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

  List<ProductVariantDraft> buildVariants() {
    return stockControllers.entries.map((entry) {
      final parts = entry.key.split('::');
      final color = parts[0];
      final size = parts.length > 1 ? parts[1] : null;
      final stock = int.tryParse(entry.value.text.trim()) ?? 0;
      return ProductVariantDraft(
        color: color,
        size: size,
        stock: stock,
      );
    }).toList();
  }

  static final _moneyPattern = RegExp(r'^\d{1,8}(\.\d{1,2})?$');

  String? validate() {
    if (nameController.text.trim().isEmpty) return 'Enter a product name.';

    final original = originalPriceController.text.trim();
    if (!_moneyPattern.hasMatch(original) || double.parse(original) <= 0) {
      return 'Enter the original price as a number, for example 1500 or 1500.50.';
    }
    final sale = salePriceController.text.trim();
    if (sale.isNotEmpty) {
      if (!_moneyPattern.hasMatch(sale) || double.parse(sale) <= 0) {
        return 'Enter the sale price as a number, for example 1200 or 1200.50.';
      }
      if (double.parse(sale) > double.parse(original)) {
        return 'The sale price cannot be higher than the original price.';
      }
    }
    if (selectedCategoryId.value == null) return 'Choose a category.';
    if (stockControllers.isEmpty) {
      return needsSize
          ? 'Pick at least one size or color and size.'
          : 'Add at least one product variant.';
    }
    for (final controller in stockControllers.values) {
      final stock = int.tryParse(controller.text.trim());
      if (stock == null || stock < 0) {
        return 'Enter the stock for every variant.';
      }
    }
    return null;
  }

  Map<String, dynamic> buildProductPayload({
    required List<String> imagePaths,
  }) {
    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category_id': selectedCategoryId.value ?? 0,
      'brand_id': selectedBrandId.value ?? 0,
      'original_price': originalPriceController.text.trim(),
      'sale_price': salePriceController.text.trim(),
      'image_paths': imagePaths,
      'variants': buildVariants()
          .map((v) => v.toJson())
          .toList(),
    };
  }

  Future<void> submitProduct({required List<String> imagePaths}) async {
    await _productRepository.createProduct(
      buildProductPayload(imagePaths: imagePaths),
    );
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