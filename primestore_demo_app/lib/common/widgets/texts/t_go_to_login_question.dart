import 'package:demo_project/features/autentication/screens/login/login.dart';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class TLoginAccountTextButton extends StatelessWidget {
  const TLoginAccountTextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () => Get.to(() => LoginScreen()),
      child: Text.rich(
      TextSpan(
      text: "Already have an account?",
      style: Theme.of(context).textTheme.bodySmall,
      children: [
      TextSpan(
      text: ' Sign In',
      style: TextStyle(
      fontWeight: FontWeight.bold,
       color: TColors.primary,
       fontSize: TSizes.md + 3
       ),
       ),
        ],
       ),
      ),
    );
  }
}