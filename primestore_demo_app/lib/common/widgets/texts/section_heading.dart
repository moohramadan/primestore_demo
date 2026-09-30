import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TSectionHeading extends StatelessWidget {
  const TSectionHeading(  {
    super.key, 
    this.textColor, 
    this.showActionButton = true, 
    required this.title, 
    this.buttonTitle = 'View ALL', 
    this.onPressed, 
    this.textButtonColor = TColors.darkGrey,
    this.fontsize = 3,
    this.fontWeightDelta  = 2,
    this.buttonFontSize = 14,
    this.buttonFontWeight = FontWeight.normal,
  });
  final Color? textColor;
  final bool showActionButton;
  final String  title, buttonTitle;
  final void Function()? onPressed;
  final Color? textButtonColor;
  final double fontsize;
  final int fontWeightDelta;
  final double buttonFontSize;
  final FontWeight buttonFontWeight;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall!.apply(color:textColor, fontSizeDelta: fontsize, fontWeightDelta: fontWeightDelta), maxLines: 1, overflow: TextOverflow.ellipsis, ),
        if(showActionButton)
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonTitle,
              style: TextStyle(
                color: textButtonColor,
                fontSize: buttonFontSize,
                fontWeight: buttonFontWeight,
              ),
            ),
          ),
      ],
    );
  }
}
