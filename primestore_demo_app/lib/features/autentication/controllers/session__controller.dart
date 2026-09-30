import 'package:get/get.dart';
import 'package:demo_project/data/repositories/auth_repository.dart';
import 'user_controller.dart';
import '../../../utils/local_storage/secure_storage_service.dart'; // adjust path

class SessionController extends GetxController {
  final RxBool isLoading = true.obs;
  final _authController = AuthController();
  late final Future<bool> autoLoginFuture;

  @override
  void onInit() {
    super.onInit();
    autoLoginFuture = tryAutoLogin();
  }

  Future<bool> tryAutoLogin() async {
    // ...unchanged...
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken == null) {
      isLoading.value = false;
      return false;
    }

    try {
      final result = await _authController.refreshSession(refreshToken);
      Get.find<UserController>().setSession(result.user, result.accessToken);
      await SecureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      isLoading.value = false;
      return true;
    } catch (e) {
      await SecureStorageService.clearTokens();
      isLoading.value = false;
      return false;
  }
}
}


