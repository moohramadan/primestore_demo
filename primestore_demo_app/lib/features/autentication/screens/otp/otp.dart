import 'package:demo_project/common/widgets/appbar/appbar.dart';
import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
import 'package:demo_project/features/autentication/screens/login/login.dart';
import 'package:demo_project/features/autentication/screens/otp/widgets/otp_pin_input.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';

import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';



class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ?  Color.fromRGBO(20, 44, 92, 1): TColors.white,
      appBar: TAppBar(
        showBackArrow: true,
      ),
      body: Column(
        children: [
          
          Image(image: AssetImage(dark? TImages.otpSentDark : TImages.otpSentLight,), height: 300, width: double.infinity,),
          Text('Verify your phone', style: Theme.of(context).textTheme.headlineLarge,),
          SizedBox(height: TSizes.md,),
          Text('Enter the 6-digit code sent to', style: Theme.of(context).textTheme.headlineSmall!.apply(color: dark? TColors.grey: TColors.darkerGrey),),
          TextButton(onPressed: (){}, child: Text('+234 8012345678', style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.primary),)),
          Padding(
            padding: EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                TotpInputWidget(),
                SizedBox(height: TSizes.spaceBtwItems,),
                TQuestionTextButton(question: "Didn't recieve the code ", answer: 'Resend code', onTap: (){}),
                SizedBox(height: TSizes.spaceBtwItems * 2,),
                TRoundedElevatedButton(color: TColors.primary, onpressed: () => Get.to(() => LoginScreen()), text: 'Verify & continue', ShowIcon: true, icon: Icons.check_box,),
          SizedBox(height: TSizes.spaceBtwSections * 4.5,),
            Text(
               '© 2026 Prime Store • All rights reserved',
               style: TextStyle(
                fontSize: 12,
                color: dark? TColors.darkerGrey: TColors.darkGrey,
               ),
             ),
              ],
            ),
            )
        ],
      ),
      
    );
  }
}