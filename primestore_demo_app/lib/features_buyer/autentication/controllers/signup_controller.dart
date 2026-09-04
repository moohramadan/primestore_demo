import 'package:demo_project/features_buyer/autentication/screens/login/login%20screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'auth_controller.dart';

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
      Get.snackbar('Success', 'Account created!', backgroundColor: Colors.green, colorText: Colors.white);
      Get.to(() => BuyerLoginScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
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
