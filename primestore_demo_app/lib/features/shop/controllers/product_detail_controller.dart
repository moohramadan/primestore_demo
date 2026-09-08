import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProductDetailController extends GetxController {
  final ProductModel product;
  ProductDetailController({required this.product});

  final RxInt quantity = 1.obs;
  late final Rx<ProductVariantModel?> selectedVariant;
  final RxString selectedColor = ''.obs;
  final RxString selectedSize = ''.obs;

  List<String> get availableColors =>
      product.variants.map((v) => v.color).where((c) => c.isNotEmpty).toSet().toList();

  List<String> get availableSizes =>
      product.variants.map((v) => v.size).where((s) => s.isNotEmpty).toSet().toList();

  @override
  void onInit() {
    super.onInit();
    final defaultVariant = product.defaultVariant;
    selectedVariant = Rx<ProductVariantModel?>(defaultVariant);
    selectedColor.value = defaultVariant?.color ?? '';
    selectedSize.value = defaultVariant?.size ?? '';
  }

  void _updateSelectedVariant() {
    ProductVariantModel? match;
    for (final v in product.variants) {
      if (v.color == selectedColor.value && v.size == selectedSize.value) {
        match = v;
        break;
      }
    }
    selectedVariant.value = match;
    quantity.value = 1;
  }

  void selectColor(String color) {
    selectedColor.value = color;
    _updateSelectedVariant();
  }

  void selectSize(String size) {
    selectedSize.value = size;
    _updateSelectedVariant();
  }

  void increment() {
    final maxStock = selectedVariant.value?.stock ?? 0;
    if (quantity.value < maxStock) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  bool get isOutOfStock => (selectedVariant.value?.stock ?? 0) <= 0;
}
