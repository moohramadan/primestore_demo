import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/texts/terms_and_conditions.dart';
import 'package:demo_project/features/autentication/screens/otp/otp.dart';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';


import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

//import 'package:iconsax/iconsax.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({super.key});

  @override
  Widget build(BuildContext context) {

    return Form(
      child: Column(
        children: [
      Row(
       children: [
        Expanded(
       child: TTextfiedRounded(labeltext: 'Firstname', hinttext: 'Firstname', icon: Icons.person)
     ),
     SizedBox(width: 10,),
     Expanded(
      child: TTextfiedRounded( labeltext: 'Lastname', hinttext: 'Lastname', icon: Icons.person,),
    ),
      
       ],
      ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
         
    
         TTextfiedRounded(labeltext: 'Email', hinttext: "example@domain", icon: Icons.mail),
    
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextfiedRounded(labeltext: 'Phone Number', hinttext: '+234 8012345678', icon: Icons.phone),
          const SizedBox(height: TSizes.spaceBtwInputFields + 5),
          Row(
          children: [
          Expanded(
          child: TTextfiedRounded(labeltext: 'Password', hinttext: 'Password', icon: Icons.lock)
          ),
           SizedBox(width: 10,),
            Expanded(
            child: TTextfiedRounded( labeltext: 'Confirm Password', hinttext: 'Confirm Password', icon: Icons.lock,),
          ),
      
       ],
      ),
          //const SizedBox(height: TSizes.spaceBtwInputFields ), 
          TTerms_conditions(),
          const SizedBox(height: TSizes.spaceBtwSections - 20),
    
          TRoundedElevatedButton(color: TColors.primary, onpressed: () => Get.to(() => OtpScreen()), text: 'Sign Up', ShowIcon: true,),
    
          const SizedBox(height: TSizes.spaceBtwItems),
          
    
          
        ],
      ),
    );
  }
}




