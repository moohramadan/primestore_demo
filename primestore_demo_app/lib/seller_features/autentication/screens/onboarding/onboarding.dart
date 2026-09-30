import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/account_type/account_type.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class ONBoardingScreen extends StatelessWidget {
  const ONBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            children: [
              SizedBox(height: TSizes.spaceBtwSections * 20),
              Text(
                'Become a seller',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Begin earning with us as a seller',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: TSizes.spaceBtwSections * 3),
              TRoundedElevatedButton(
                onPressed: () => Get.to(() => const AccountTypeScreen()),
                text: "Get Started",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
