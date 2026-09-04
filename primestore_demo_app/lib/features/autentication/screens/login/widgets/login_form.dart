import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/features/autentication/screens/forget_password/forget_password.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/login_slider.dart';
import 'package:demo_project/features/shop/screens/navigation%20menu.dart';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/text_strings.dart';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
//import 'package:iconsax/iconsax.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SlideController>();
    //final dark = THelperFunctions.isDarkMode(context);
    return Form(
      child: Column(
        children: [
         
        Obx(() {
  if (controller.isEmail.value) {
    return TTextfiedRounded(labeltext: "Email", hinttext: "example@gmail.com", icon: Icons.mail);
  } else {
    return TTextfiedRounded(
      labeltext: 'Phone',
      hinttext: '234 8012345678',
      icon: Icons.phone,
    );
  }
}),

    
          const SizedBox(height: TSizes.spaceBtwInputFields *1.2),
    
          TTextfiedRounded(labeltext: 'Password', hinttext: 'Enter your password', icon: Icons.lock),
    
          
    
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: true,
                    checkColor: TColors.white,
                    onChanged: null,
                  ),
                  const Text(TTexts.rememberMe),
                ],
              ),
    
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red
                  
                ),
                onPressed: () => Get.to(() => ForgetPasswordScreen()),
                child: const Text(TTexts.forgetPassword, style: TextStyle(fontSize: TSizes.md -2, fontWeight: FontWeight.w800),),
              ),
            ],
          ),
    
          const SizedBox(height: TSizes.spaceBtwItems),
    
          TRoundedElevatedButton(color: TColors.primary, onpressed: () => Get.to(() => NavigationMenu()), text: 'Sign In', ShowIcon: true, ),
    
          const SizedBox(height: TSizes.spaceBtwItems),
    
          
        ],
      ),
    );
  }
}

