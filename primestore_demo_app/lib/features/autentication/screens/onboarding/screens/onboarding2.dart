import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/features/autentication/controllers/onboarding_progress_indicator.dart';
import 'package:demo_project/features/autentication/screens/onboarding/screens/onboarding3.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Onboarding2Content();
  }
}

class _Onboarding2Content extends StatefulWidget {
  const _Onboarding2Content();

  @override
  State<_Onboarding2Content> createState() => _Onboarding2ContentState();
}

class _Onboarding2ContentState extends State<_Onboarding2Content> {
  static const _userTypes = [
    ('Buyer', 'I’m here to discover and shop for products.'),
    ('Seller', 'I’m here to showcase and sell my products.'),
  ];

  String _selectedUserType = 'Buyer';

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      
      appBar: AppBar(
        leading: BackButton(color: dark ? TColors.white : TColors.dark),
        title: const OnboardingProgressIndicator(currentStep: 2),
        actions: [
          Text('2/3', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: TSizes.lg),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: TSizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const THeadline(title: 'What brings you here?', maxLines: 2),
              const SizedBox(height: TSizes.sm),
              const TSubtitle(title: 'Choose how you’d like to use the app.'),
              const SizedBox(height: TSizes.spaceBtwItems),
              for (final userType in _userTypes) ...[
                _UserTypeOption(
                  title: userType.$1,
                  description: userType.$2,
                  selected: _selectedUserType == userType.$1,
                  onTap: () => setState(() => _selectedUserType = userType.$1),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
              ],
              const Spacer(),
              TRoundedElevatedButton(
                onPressed: () => Get.to(() => const Onboarding3()),
                text: 'Continue',
              ),
              const SizedBox(height: TSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  const _UserTypeOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final borderColor = selected
        ? TColors.primary
        : (isDark ? TColors.darkerGrey : TColors.borderSecondary);
    final titleColor = isDark ? TColors.white : TColors.textPrimary;
    final descriptionColor = isDark ? TColors.grey : TColors.darkerGrey;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? TColors.primary : descriptionColor,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: TSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: descriptionColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
