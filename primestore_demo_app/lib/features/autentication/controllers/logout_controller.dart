import 'package:demo_project/features/autentication/controllers/auth_controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/login/login%20screen.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LogoutController extends GetxController {
  Future<void> handleLogout() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken != null) {
      await AuthController().logout(refreshToken);
    }
    await SecureStorageService.clearTokens();
    Get.find<UserController>().clearSession();
    Get.offAll(() => LoginScreen());
  }
}
