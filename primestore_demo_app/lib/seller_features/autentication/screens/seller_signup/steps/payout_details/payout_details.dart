import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/account_created/account_created.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/payout_details/widgets/payout_form.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/widgets/seller_signup_progress_indicator.dart';
import 'package:demo_project/seller_features/autentication/models/seller_signup_data.dart';
import 'package:demo_project/data/repositories/seller_repository.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class PayoutDetailsScreen extends StatefulWidget {
  const PayoutDetailsScreen({super.key, this.signupData});

  final SellerSignupData? signupData;

  @override
  State<PayoutDetailsScreen> createState() => _PayoutDetailsScreenState();
}

class _PayoutDetailsScreenState extends State<PayoutDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _sellerRepository = SellerRepository();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      //backgroundColor: dark ? TColors.dark : TColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: dark ? TColors.white : TColors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SellerSignupProgressIndicator(currentStep: 3),
            const SizedBox(height: TSizes.spaceBtwSections),
            const THeadline(title: 'Payout details'),
            const SizedBox(height: TSizes.sm),
            const TSubtitle(
              title: 'Add the bank account where you want to receive payouts',
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Expanded(
              child: SingleChildScrollView(
                child: PayoutForm(
                  formKey: _formKey,
                  accountHolderController: _accountHolderController,
                  bankNameController: _bankNameController,
                  accountNumberController: _accountNumberController,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedElevatedButton(
              onPressed: _isSubmitting ? null : _submitSellerProfile,
              text: 'Continue',
            ),
            const SizedBox(height: TSizes.spaceBtwItems * 2),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSellerProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final signupData = widget.signupData;
    if (signupData == null) {
      Get.snackbar(
        'Payout details',
        'Payout account updates are not available yet.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _sellerRepository.createSellerProfile(
        signupData: signupData,
        accountHolderName: _accountHolderController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
      );
      if (!mounted) return;
      Get.offAll(() => const AccountCreatedScreen());
    } catch (error) {
      if (!mounted) return;
      Get.snackbar('Could not create seller account', error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
