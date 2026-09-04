  import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/text_strings.dart';



import 'package:flutter/material.dart';
class TTerms_conditions extends StatelessWidget {
  const TTerms_conditions({
    super.key,
  });

@override
  Widget build(BuildContext context) {
   //final dark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Checkbox(
          value: true,
          checkColor: TColors.white,
          onChanged: null,
        ),
        GestureDetector(
      onTap: () {},
      child: Text.rich(
      TextSpan(
      text: "I agree",
      style: Theme.of(context).textTheme.bodySmall,
      children: [
      TextSpan(
      text: TTexts.termsOfUse,
      style: TextStyle(
        
      
       color: TColors.primary
       ),
       ),
        ],
       ),
      ),
    ),
      ],
    );
  }
}