import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/features/autentication/screens/email_change_otp/email_change_otp.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditEmailScreen extends StatelessWidget {
  EditEmailScreen({super.key});

  final controller = Get.put(EditEmailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'We\'ll send a confirmation to your new email before it '
                'becomes active on your account.',
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.3),
              ),
              const SizedBox(height: 24),
              TTextFieldRounded(
                controller: controller.emailController,
                hintText: 'Write new email',
                keyboardType: TextInputType.emailAddress,
                validator: TValidator.validateEmail,
                hintTextStyle: TextStyle(fontSize: TSizes.md),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      final email = controller.emailController.text.trim();
                      Get.to(() => EmailChangeOtp(email: email));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.black,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text('Update', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditEmailController extends GetxController {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}