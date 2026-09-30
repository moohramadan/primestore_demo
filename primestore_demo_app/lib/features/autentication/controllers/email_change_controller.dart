import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EmailChangeController extends GetxController {
  final pinController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString otpToken = ''.obs;

  final String newEmail;
  final _authController = AuthController();

  EmailChangeController({required this.newEmail});

  @override
  void onInit() {
    super.onInit();
    sendCode();
  }

  Future<void> sendCode() async {
    isLoading.value = true;
    try {
      final accessToken = Get.find<UserController>().accessToken.value;
      final token = await _authController.requestEmailChange(accessToken, newEmail);
      otpToken.value = token;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verify(String code) async {
    if (otpToken.value.isEmpty) {
      Get.snackbar('Please wait', 'Still sending your code — try again in a moment.');
      return;
    }
    isLoading.value = true;
    try {
      final accessToken = Get.find<UserController>().accessToken.value;
      final user = await _authController.confirmEmailChange(otpToken.value, code, accessToken);
      Get.find<UserController>().updateUser(user);
      Get.snackbar('Success', 'Email updated!');
      Get.back(); // closes the OTP screen
      Get.back(); // closes the edit-email screen, back to Account
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    super.onClose();
  }
}