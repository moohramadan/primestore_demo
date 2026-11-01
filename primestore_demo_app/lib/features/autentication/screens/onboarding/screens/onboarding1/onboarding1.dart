import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/features/autentication/controllers/onboarding_progress_indicator.dart';
import 'package:demo_project/features/autentication/screens/onboarding/screens/onboarding1/widgets/selector.dart';
import 'package:demo_project/features/autentication/screens/onboarding/screens/onboarding2.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Onboarding1 extends StatelessWidget {
   Onboarding1({super.key});

final c = Get.put(InterestController());

  @override
  Widget build(BuildContext context) {
    final dark= THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      
      appBar: AppBar(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            THeadline(title: 'What products peek your interest', maxLines: 2,),
            SizedBox(height: TSizes.xs,),
            Text("select the categories you'd like to shop", style: Theme.of(context).textTheme.bodySmall,),
            SizedBox(height: TSizes.spaceBtwInputFields,),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: c.Interests.map(TBuildChip).toList(),
            ),
             
            Spacer(),
            TRoundedElevatedButton(onPressed: ()  => Get.to(() => Onboarding2()), text: 'Continue'),
            SizedBox(height: TSizes.defaultSpace,),
           
          ],
        ),
      ),
    );
  }
  Widget TBuildChip(String Interest){
    return GestureDetector(
      onTap: () => c.toggleInterest(Interest),
      child: Obx((){
        final selected = c.isSelected(Interest);
        return AnimatedContainer(
          
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal:  TSizes.md, vertical: TSizes.xs, ),
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color:selected? TColors.primary.withValues(alpha: 0.08) : TColors.white,
            border: Border.all(
              color: selected? TColors.primary: TColors.black,
              width: selected? 1.6 : 1,
            )
          ),
           child: Text(Interest, style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:selected?  TColors.primary: TColors.black
           )),
          );
        

      }),
    );
  }
}