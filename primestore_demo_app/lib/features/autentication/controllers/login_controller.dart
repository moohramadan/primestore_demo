

import 'package:demo_project/features/autentication/screens/login/widgets/glass_login_slider.dart';
import 'package:demo_project/features/shop/screens/navigation%20menu.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'auth_controller.dart';
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
    await _authController.login(
      email: slideController.isEmail.value ? emailController.text : null,
      phone: slideController.isEmail.value ? null : phoneController.text,
      password: passwordController.text,
    );
    Get.snackbar('Success', 'Logged in!', backgroundColor: Colors.green, colorText: Colors.white);
    Get.to(() => NavigationMenu());
  } catch (e) {
    Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
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