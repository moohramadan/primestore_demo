import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/navigation/seller_nav.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/widgets/seller_signup_progress_indicator.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final textColor = isDark ? TColors.white : TColors.black;
    final mutedColor = isDark ? TColors.grey : TColors.darkerGrey;
    final successTint = isDark
        ? const Color(0xFF173C30)
        : const Color(0xFFE7F5EE);

    return Scaffold(
      //backgroundColor: isDark ? TColors.dark : TColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: TSizes.spaceBtwSections,
          ),
          child: Column(
            children: [
              const SellerSignupProgressIndicator(currentStep: 4),
              const Spacer(),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: successTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF22845A),
                  size: 58,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                'Your seller account is ready',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TSizes.md),
              Text(
                'Your setup is complete. You can verify your identity later from your profile. Head to your dashboard to manage your store and prepare your first listing.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: mutedColor, height: 1.5),
              ),
              const Spacer(),
              TRoundedElevatedButton(
                onPressed: () => Get.offAll(() => const SellerNavigationMenu()),
                text: 'Go to seller dashboard',
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
