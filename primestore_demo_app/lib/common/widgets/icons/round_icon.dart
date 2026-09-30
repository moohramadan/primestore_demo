import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TRoundedIcon extends StatelessWidget {
  const TRoundedIcon({
    super.key,
    
    this.iconSize = TSizes.lg + 3,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = TSizes.borderRadiusXxl,
    this.iconColor, 
    required this.icon,
  });

  final IconData icon;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.grey,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}