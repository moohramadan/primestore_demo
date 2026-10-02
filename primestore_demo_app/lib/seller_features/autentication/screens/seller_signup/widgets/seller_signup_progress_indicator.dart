import 'package:demo_project/seller_features/autentication/controllers/progress_indicator_controller.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class SellerSignupProgressIndicator extends StatelessWidget {
  const SellerSignupProgressIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return LinearProgressIndicator(
      value: currentStep / ProgressIndicatorController.totalSteps,
      color: TColors.primary,
      backgroundColor: isDark ? TColors.white : TColors.black,
    );
  }
}
