

import 'package:demo_project/common/widgets/form_diver.dart';
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/social_buttons.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
//import 'package:demo_project/common/widgets/texts/login_heading.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/login_form.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/login_slider.dart';
import 'package:demo_project/features/autentication/screens/signup/signup.dart';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';

//import 'package:demo_project/utils/constants/text_strings.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
      Get.put(SlideController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ?  TColors.scaffoldDarkBlue1: TColors.white,
      body:  Column(
        children: [
          Container(
            padding: EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
             children: [
              SizedBox(height: TSizes.spaceBtwInputFields,),
              TRoundedImage(imageUrl: TImages.brandImage3, height: 100, width: 100,),
              SizedBox(height: TSizes.spaceBtwInputFields,),
              Text('Sign In     ', style: Theme.of(context).textTheme.headlineLarge!.apply(),)
              
              
             ],
            ),
          ),
            SizedBox(height: TSizes.spaceBtwSections - 10,),
            Column(
              children: [
                
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
                 ],

              ),
                padding: EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    LoginSlider(),
                    SizedBox(height: TSizes.spaceBtwInputFields *1.2,),
                    TLoginForm(),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TFormDivider(dividerText: 'Or login with'),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TSocialButtons(),
                    SizedBox(height: TSizes.spaceBtwSections,),
                    TQuestionTextButton(question: "Don't have an account?", answer: ' Sign Up', onTap: () => Get.to(() => SignupSreen()),)
                  ],
                ),
               ),
               SizedBox(height: TSizes.spaceBtwSections,),
               Text(
               '© 2026 Prime Store • All rights reserved',
               style: TextStyle(
                fontSize: 12,
                color: dark? TColors.darkerGrey: TColors.darkGrey,
               ),
             ),
              ],
            )
        ],
      ),
    );
  }
}

