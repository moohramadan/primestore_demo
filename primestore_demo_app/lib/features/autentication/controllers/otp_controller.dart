import 'package:demo_project/features/autentication/screens/login/login%20screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'auth_controller.dart';

class OtpController extends GetxController {
  final pinController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString otpToken = ''.obs;

  final String email;
  final _authController = AuthController();

  OtpController({required this.email});

  @override
  void onInit() {
    super.onInit();
    sendCode();
  }

  Future<void> sendCode() async {
  isLoading.value = true;
  try {
    final token = await _authController.sendOtp(email);
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
    await _authController.confirmOtp(otpToken.value, code);
    Get.snackbar('Success', 'Email verified!');
    Get.offAll(() => LoginScreen());
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
