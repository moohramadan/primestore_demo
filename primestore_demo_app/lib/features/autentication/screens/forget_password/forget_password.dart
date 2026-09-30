import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/appbar/appbar.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_login_slider.dart';


import 'package:demo_project/features/autentication/screens/otp/otp.dart';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GlassSlideController>();
  
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ?  Color.fromRGBO(20, 44, 92, 1): TColors.white,
      appBar: TAppBar(
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(horizontal:  TSizes.defaultSpace), child: Column(
            children: [
          Image(image: AssetImage(dark? TImages.sendEmailImageDark: TImages.sendEmailImageLight)),
          Text("Forgot Password?", style: Theme.of(context).textTheme.headlineLarge, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
          SizedBox(height: TSizes.spaceBtwInputFields,),
          Text("Enter your registered mobile number in the field below", style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
          SizedBox(height: TSizes.spaceBtwSections,),
          GlassLoginSlider(),
          SizedBox(height: TSizes.spaceBtwSections,),
          Obx(() {
          if (controller.isEmail.value) {
          return TTextFieldRounded(labelText: "Email", hintText: "example@domain", icon: Icons.mail);
          } else {
           return TTextFieldRounded(
          labelText: 'Phone',
         hintText: '234 8012345678',
         icon: Icons.phone,
         );
          }
          }),
          SizedBox(height: TSizes.spaceBtwSections,),
          TRoundedElevatedButton(color: TColors.primary, onPressed: () => Get.to(()=> OtpScreen()), text: 'Next', ),
          SizedBox(height: TSizes.spaceBtwSections * 2,),
            Text(
               '© 2026 Prime Store • All rights reserved',
               style: TextStyle(
                fontSize: 12,
                color: dark? TColors.darkerGrey: TColors.darkGrey,
               ),
             ),
            ],
          ),),
          
          
        ],
      ),
    );
  }
} 