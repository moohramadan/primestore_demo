
import 'package:demo_project/utils/constants/colors.dart';
//import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class TSocialButtons extends StatelessWidget {
  const TSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
   final dark = THelperFunctions.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: TSizes.iconLg, vertical: TSizes.md),
          decoration: BoxDecoration(
            color :dark? Color.fromRGBO(20, 25, 39, 1): const Color.fromARGB(255, 238, 238, 238),
            border: Border.all(color:dark? Color.fromRGBO(20, 25, 39, 1): TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              

           // Google Icon
            FaIcon( 
            FontAwesomeIcons.google,
            color: Colors.red,        // or keep original colors if you want
            size: 20,
            ),

             SizedBox(width: 10,),

              Text('Google', style: Theme.of(context).textTheme.titleMedium,)
            ],
          ),
        ),
        SizedBox(width: TSizes.spaceBtwItems),
        Container(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.md),
          decoration: BoxDecoration(
                       color :dark? Color.fromRGBO(20, 25, 39, 1): const Color.fromARGB(255, 238, 238, 238),
            border: Border.all(color:dark? Color.fromRGBO(20, 25, 39, 1): TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              FaIcon(
               FontAwesomeIcons.facebook,
              color: Color(0xFF1877F2), // official Facebook blue
                size: 24,
               ),
               SizedBox(width: 10,),
              Text('facebook', style: Theme.of(context).textTheme.titleMedium,)
            ],
          ),
        ),
      ],
    );
  }
}