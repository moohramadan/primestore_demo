import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/otp/otp.dart';
import 'package:demo_project/navigation/navigation%20menu.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

// wherever this lives

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final _authController = AuthController();

  Future<void> login() async {
    isLoading.value = true;
    try {
      final result = await _authController.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.find<UserController>().setSession(result.user, result.accessToken);
      await SecureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      Get.snackbar('Success', 'Logged in!');
      Get.to(() => NavigationMenu());
    } on UnverifiedEmailException {
      Get.snackbar(
        'Verify your email',
        'Please verify your email to continue.',
      );
      Get.to(() => OtpScreen(email: emailController.text.trim()));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
