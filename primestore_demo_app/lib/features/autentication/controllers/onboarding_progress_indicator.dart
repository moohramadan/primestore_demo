

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator ({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
   
    return LinearProgressIndicator(
      value: currentStep / OnboardingProgressIndicatorController.totalSteps,
      color: TColors.primary,
      backgroundColor: isDark ? TColors.white : TColors.black,
    );
  }
}


class OnboardingProgressIndicatorController extends GetxController {
  //Total number of screen
  static const int totalSteps = 3;
}

