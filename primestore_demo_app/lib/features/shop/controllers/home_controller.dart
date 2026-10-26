import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/data/repositories/product_repository.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductOption> categories = <ProductOption>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingCategories = true.obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnString categoriesError = RxnString();
  final RxnString productsError = RxnString();

  final _authController = AuthController();
  final _productRepository = ProductRepository();
  int _productRequest = 0;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchFeaturedProducts();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    categoriesError.value = null;
    try {
      categories.assignAll(await _productRepository.fetchCategories());
    } catch (error) {
      categoriesError.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchFeaturedProducts() => selectCategory(null);

  Future<void> selectCategory(int? categoryId) async {
    selectedCategoryId.value = categoryId;
    final request = ++_productRequest;
    isLoading.value = true;
    productsError.value = null;
    try {
      final products = categoryId == null
          ? await _authController.getFeaturedProducts()
          : await _productRepository.fetchProductsByCategory(categoryId);
      if (request == _productRequest) {
        featuredProducts.assignAll(products);
      }
    } catch (error) {
      if (request == _productRequest) {
        productsError.value = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
        Get.snackbar(
          'Could not load products',
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (request == _productRequest) isLoading.value = false;
    }
  }

  Future<void> retrySelectedCategory() =>
      selectCategory(selectedCategoryId.value);

  String get selectedCategoryName {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) return 'Featured Products';
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'Products';
  }
}
