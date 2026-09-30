import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/models/user_model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final _authController = AuthController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final accessToken = Get.find<UserController>().accessToken.value;
      final freshUser = await _authController.getMe(accessToken);
      user.value = freshUser;
      Get.find<UserController>().currentUser.value = freshUser; // keep global state in sync too
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
