

import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_login_slider.dart';
import 'package:demo_project/features/autentication/screens/otp/otp.dart';
import 'package:demo_project/features/shop/screens/navigation%20menu.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


// wherever this lives

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final _authController = AuthController();

Future<void> login() async {
  final slideController = Get.find<GlassSlideController>();

  isLoading.value = true;
  try {
    final result = await _authController.login(
      email: slideController.isEmail.value ? emailController.text : null,
      phone: slideController.isEmail.value ? null : phoneController.text,
      password: passwordController.text,
    );
    Get.find<UserController>().setSession(result.user, result.accessToken);
    await SecureStorageService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    Get.snackbar('Success', 'Logged in!');
    Get.to(() => NavigationMenu());
  } on UnverifiedEmailException catch (e) {
    Get.snackbar('Verify your email', 'Please verify your email to continue.');
    Get.to(() => OtpScreen(email: emailController.text));
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}



  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}