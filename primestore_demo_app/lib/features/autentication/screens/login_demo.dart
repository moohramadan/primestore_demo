import 'package:demo_project/common/widgets/textfield/texxtfleld_circular.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class LoginDemoScreen extends StatelessWidget {
  const LoginDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
    
     body: Padding(
       padding: const EdgeInsets.all(TSizes.defaultSpace),
       child: Column(
        children: [
          Padding(padding: EdgeInsets.all(TSizes.defaultSpace)),
          Center(child: Image(image: AssetImage(TImages.brandImage3), height: 100, width: 100,)),
          SizedBox(height: TSizes.sm,),
          Text('Sign In', style: Theme.of(context).textTheme.headlineLarge,),
          SizedBox(height: TSizes.spaceBtwSections + 20,),
          Container(
            
            decoration: BoxDecoration(
              
            ),
            child: Column(
              children: [
               CTextfield(dark: dark, labelText: 'Email', hintText: 'example@email.com', icon: Icons.mail,),
               SizedBox(height: TSizes.spaceBtwInputFields,),
               CTextfield(dark: dark, labelText: 'Password', hintText: '**********', icon: Icons.lock,),
                SizedBox(height: TSizes.spaceBtwInputFields,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_box, color:  Colors.blue,),
                        SizedBox(width: 8,),
                        Text('Remember me'),
                      ],
                    ),
                    TextButton(onPressed: (){}, child: Text('Forget Password?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),))
                  ],
                )
                
              ],
            ),
          )

        ],
       ),
     ),
    );
  }
}

