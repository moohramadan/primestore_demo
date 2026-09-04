
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';


import 'package:flutter/material.dart';


class TQuestionTextButton extends StatelessWidget {
  const TQuestionTextButton({
    super.key, required this.question, required this.answer, required this.onTap,
  });
  final String question,answer;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    //final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
      TextSpan(
      text: question,
      style: Theme.of(context).textTheme.bodySmall,
      children: [
      TextSpan(
      text: answer,
      style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: TSizes.md + 2,
       color: TColors.primary
       ),
       ),
        ],
       ),
      ),
    );
  }
}