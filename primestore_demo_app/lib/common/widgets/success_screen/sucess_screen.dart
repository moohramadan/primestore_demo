

import 'package:demo_project/common/styles/spacing_styles.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/text_strings.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.image, required this.title, required this.subtitle, required this.onpressed});
  final String image, title, subtitle;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
        padding: TSpacingStyle2.paddingWithAppBarHeight,
        child: Column(
         ///images
        children: [Image(image: AssetImage(image), width: THelperFunctions.screenWidth() * 0.6,),
        SizedBox(height: TSizes.spaceBtwItems,),
         ///Title & subtitle
         Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
         const SizedBox(height: TSizes.spaceBtwItems,),
         Text(subtitle, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
        const SizedBox(height: TSizes.spaceBtwSections,),

        ///buttons
        SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onpressed, child: Text(TTexts.tContinue)),
              ),
              const SizedBox(height: TSizes.spaceBtwItems,),
              
        ]
        ),
          ),
      ),
    );
  }
}