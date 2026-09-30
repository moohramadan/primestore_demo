
import 'package:demo_project/features/autentication/screens/otp/otp.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:demo_project/data/repositories/auth_repository.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final _authController = AuthController();

  Future<void> signUp() async {
  isLoading.value = true;
  try {
    await _authController.signUp(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      phone: phoneController.text,
    );
    Get.snackbar('Success', 'Account created!');
    Get.to(() => OtpScreen(email: emailController.text));
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}


  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
