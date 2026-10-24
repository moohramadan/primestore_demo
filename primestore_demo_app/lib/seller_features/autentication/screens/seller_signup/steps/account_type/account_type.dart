import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/account_type/widgets/account_type_option.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/business_details/business_details.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/widgets/seller_signup_progress_indicator.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountTypeContent();
  }
}

class _AccountTypeContent extends StatefulWidget {
  const _AccountTypeContent();

  @override
  State<_AccountTypeContent> createState() => _AccountTypeContentState();
}

class _AccountTypeContentState extends State<_AccountTypeContent> {
  static const _accountTypes = [
    (
      'individual',
      'Individual',
      "I'm selling as an individual\n(not a registered business).",
    ),
    (
      'private_business',
      'Private business',
      "I'm a registered business\n(e.g. LLC, Ltd, etc.).",
    ),
    ('public_business', 'Public business', "I'm a publicly traded company."),
    (
      'non_profit',
      'Non-profit',
      "I'm a registered non-profit\norganization.",
    ),
  ];

  String _selectedAccountType = 'individual';

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      //backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: isDark ? TColors.white : TColors.black),
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
                      const SellerSignupProgressIndicator(currentStep: 1),
                      SizedBox(height: TSizes.spaceBtwSections),
                      const THeadline(
                        title: 'What type of seller are you?',
                        maxLines: 2,
                      ),
                      const SizedBox(height: TSizes.sm),
                      const TSubtitle(
                        title:
                            'Tell us about your business structure. You can always change this later.',
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      for (final accountType in _accountTypes) ...[
                        AccountTypeOption(
                          title: accountType.$2,
                          description: accountType.$3,
                          selected: _selectedAccountType == accountType.$1,
                          onTap: () => setState(
                            () => _selectedAccountType = accountType.$1,
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                      ],
                    ],
                  ),
                ),
              ),
              TRoundedElevatedButton(
                onPressed: () => Get.to(
                  () =>
                      BusinessDetailsScreen(accountType: _selectedAccountType),
                ),
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
