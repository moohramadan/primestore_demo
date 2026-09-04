
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TCircularIcon extends StatelessWidget {
  const TCircularIcon({
    super.key,
    
    this.width,
    this.height,
    this.size = TSizes.lg,
     required this.icon,
     this.color,
     this.backgroundColor,
     this.onPressed,
     this.padding = 0,
  });

  
  final double? width, height, size;
  final IconData icon;
  final Color?color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: backgroundColor != null
           ? backgroundColor !
           :THelperFunctions.isDarkMode(context)
            ? TColors.black.withValues(alpha: 0.9)
            : TColors.white.withValues(alpha: 0.9),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: size),
      ),
    );
  }
}
