import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/identity_verification/identity_verification.dart';
import 'package:demo_project/seller_features/personalization/screens/seller_setting/seller_setting.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final mutedColor = isDark ? TColors.grey : TColors.darkerGrey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Get.to(() => const SellerSettingScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(
                title: 'Seller profile',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: isDark ? TColors.darkGrey : TColors.light,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          'Identity verification',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      'Verify your identity after signing up to help build trust with customers.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TRoundedElevatedButton(
                      onPressed: () =>
                          Get.to(() => const IdentityVerificationScreen()),
                      text: 'Verify my profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
