import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/business_details/widgets/business_form.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/payout_details/payout_details.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/widgets/seller_signup_progress_indicator.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key, this.accountType});

  final String? accountType;

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: dark ? TColors.white : TColors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SellerSignupProgressIndicator(currentStep: 2),
              const SizedBox(height: TSizes.spaceBtwSections),
              const THeadline(title: 'Business details'),
              const SizedBox(height: TSizes.sm),
              const TSubtitle(
                title: 'Let your customers know where to reach you',
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              BusinessForm(
                formKey: _formKey,
                businessNameController: _businessNameController,
                phoneNumberController: _phoneNumberController,
                addressController: _addressController,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Spacer(),
              TRoundedElevatedButton(
                onPressed: () => Get.to(() => PayoutDetailsScreen()),
                text: 'Continue',
              ),
              const SizedBox(height: TSizes.spaceBtwItems * 2),
            ],
          ),
        ),
      ),
    );
  }
}
