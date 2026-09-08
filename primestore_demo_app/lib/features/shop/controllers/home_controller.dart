import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final _authController = AuthController(); // wherever getFeaturedProducts lives

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProducts();
  }

  Future<void> fetchFeaturedProducts() async {
    isLoading.value = true;
    try {
      final products = await _authController.getFeaturedProducts();
      featuredProducts.value = products;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
