import 'package:demo_project/common/widgets/custom_shapes/containers/primary_header_container.dart';

import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/social_buttons.dart';
import 'package:demo_project/common/widgets/texts/t_go_to_login_question.dart';
import 'package:demo_project/features/autentication/screens/signup/widgets/signup_form.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/text_strings.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class SignupSreen extends StatelessWidget {
  const SignupSreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ?  Color.fromRGBO(20, 25, 39, 1): TColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(
              height: 240,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.all(TSizes.defaultSpace),
                    child: Column(
                      children: [
                        SizedBox(height: TSizes.lg,),
                        TRoundedImage(imageUrl: TImages.brandImage3, height: 100, width: 100,),
                        SizedBox(height: TSizes.lg,),
                        Text(TTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium,),
                      ],
                    ),
                    )
                ],
              ),
              
              ),
              
            Container(
               decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                color: dark? const Color.fromRGBO(24, 33, 51, 1): TColors.white,
                boxShadow: [

                  BoxShadow(

                 color: Colors.black.withValues(alpha:  0.1),
                 blurRadius: 10,
                spreadRadius: 2,
                 offset: const Offset(0, 4),
                ),
                 ]
              ),
              padding: EdgeInsets.all(TSizes.defaultSpace -10),
              child: Column(
                children: [
                  TSignupForm(),
                  TSocialButtons(),
                  
                ],
              ),
               
              ),
              SizedBox(height: TSizes.spaceBtwItems,),
              TLoginAccountTextButton(),
              SizedBox(height: TSizes.spaceBtwSections * 2,),
              Text(
               '© 2026 Prime Store • All rights reserved',
               style: TextStyle(
                fontSize: 12,
                color: dark? TColors.darkerGrey: TColors.darkGrey,
               ),
             ),
          ],
        ),
      ),
        
        
    );
  }
}