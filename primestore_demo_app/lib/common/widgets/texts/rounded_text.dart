import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';


class TRoundedText extends StatelessWidget {
  const TRoundedText( {
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(
      horizontal: TSizes.md,
      vertical: TSizes.sm,
    ),
    this.borderRadius = TSizes.borderRadiusXxl,
    this.backgroundColor,
    this.darkBackgroundColor,
    this.textStyle,
    this.fontSize,
    this.fontWeight,
    this.darkTextColor, 
    this.lightTextColor,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  final String text;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? darkBackgroundColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? darkTextColor, lightTextColor;
  final AlignmentGeometry alignment;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final defaultTextStyle = Theme.of(context).textTheme.titleLarge!;
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: dark
            ? darkBackgroundColor ?? TColors.darkerGrey
            : backgroundColor ?? TColors.black,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: (textStyle ?? defaultTextStyle).copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: dark 
          ? darkTextColor?? TColors.grey
          : lightTextColor?? TColors.white,
        ),
      ),
    );
  }
}