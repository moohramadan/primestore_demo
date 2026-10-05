import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/features/autentication/controllers/onboarding_progress_indicator.dart';
import 'package:demo_project/utils/constants/colors.dart';

import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  
  @override
  Widget build(BuildContext context) {
     final dark= THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar:  AppBar(
        leading: BackButton(color: dark? TColors.white: TColors.dark,),
        title: OnboardingProgressIndicator(currentStep: 1),
        actions: [
          Text('1/3', style: Theme.of(context).textTheme.bodySmall,),
          SizedBox(width: TSizes.lg,)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.defaultSpace),
        child: Column(
          children: [
            
            Spacer(),
            TRoundedElevatedButton(onPressed:() {}, text: 'Continue'),
            SizedBox(height: TSizes.defaultSpace,),
          ],
        ),
      ),
    );
  }
}