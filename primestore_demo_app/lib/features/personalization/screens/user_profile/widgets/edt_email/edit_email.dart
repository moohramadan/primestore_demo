import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/features/autentication/screens/email_change_otp/email_change_otp.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditEmailScreen extends StatelessWidget {
  EditEmailScreen({super.key});

  final controller = Get.put(EditEmailController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor:dark?TColors.black:  TColors.white,
        elevation: 0,
        centerTitle: true,
        leading:  BackButton(color:dark? TColors.white: Colors.black),
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: 6),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Email',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
               Text(
                'We\'ll send a confirmation to your new email before it '
                'becomes active on your account.',
                style: Theme.of(context).textTheme.bodyMedium,
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
              TRoundedElevatedButton(
                onPressed:  () {
                    if (controller.formKey.currentState!.validate()) {
                      final email = controller.emailController.text.trim();
                      Get.to(() => EmailChangeOtp(email: email));
                    }
                  }, text: "Update"),
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