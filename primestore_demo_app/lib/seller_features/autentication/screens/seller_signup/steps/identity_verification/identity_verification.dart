import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/upload_documents/upload_documents.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final mutedColor = isDark ? TColors.grey : TColors.darkerGrey;
    final tintColor = isDark
        ? TColors.primary.withValues(alpha: 0.18)
        : TColors.primary.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: isDark ? TColors.white : TColors.black,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const THeadline(title: 'Identity verification'),
                      const SizedBox(height: TSizes.sm),
                      const TSubtitle(
                        title:
                            'We need to verify your identity to keep our marketplace safe.',
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      _VerificationMethod(
                        icon: Icons.badge_outlined,
                        title: 'Government-issued ID',
                        description:
                            'National ID, passport, or driver\'s license',
                        tintColor: tintColor,
                        mutedColor: mutedColor,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _VerificationMethod(
                        icon: Icons.home_work_outlined,
                        title: 'Proof of address',
                        description: 'Utility bill, bank statement, etc.',
                        tintColor: tintColor,
                        mutedColor: mutedColor,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _VerificationMethod(
                        icon: Icons.face_retouching_natural,
                        title: 'Face verification',
                        description: 'Take a selfie for facial matching',
                        tintColor: tintColor,
                        mutedColor: mutedColor,
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.video_camera_front_outlined,
                            color: mutedColor,
                          ),
                          const SizedBox(width: TSizes.sm),
                          Expanded(
                            child: TSubtitle(
                              title:
                                  'You can also complete verification via a short video call if needed.',
                              textColor: mutedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TSizes.md),
                        decoration: BoxDecoration(
                          color: tintColor,
                          borderRadius: BorderRadius.circular(
                            TSizes.cardRadiusLg,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: TColors.primary,
                            ),
                            const SizedBox(width: TSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your information is secure',
                                    style: TextStyle(
                                      color: TColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: TSizes.xs),
                                  TSubtitle(
                                    title:
                                        'We use industry-standard encryption to protect your data.',
                                    textColor: mutedColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TRoundedElevatedButton(
                onPressed: () => Get.to(() => UploadVerificationDocuments()),
                text: 'Continue',
                borderRadius: 24,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationMethod extends StatelessWidget {
  const _VerificationMethod({
    required this.icon,
    required this.title,
    required this.description,
    required this.tintColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color tintColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: tintColor, shape: BoxShape.circle),
          child: Icon(icon, color: TColors.primary, size: TSizes.iconMd),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TSizes.xs),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
