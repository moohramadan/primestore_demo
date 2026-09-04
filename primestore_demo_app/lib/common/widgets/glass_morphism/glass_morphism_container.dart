import 'dart:ui';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TGlassMorphism extends StatelessWidget {
  const TGlassMorphism(   {
    super.key,
    this.padding =const EdgeInsets.all(8),
    this.borderRadius= 30,
    this.height,
    this.width,
    required this.child,
    this.lightcolor = TColors.white,
    this.darkcolor = TColors.white,
    this.borderColorLight = TColors.white,
    this.borderColorDark = TColors.white
    
    
    });

  final EdgeInsets padding;
  final double borderRadius;
  final double ?height, width;
  final Widget  child;
  final Color  lightcolor,darkcolor;
  final Color  borderColorLight, borderColorDark;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return ClipRRect(
     borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
       filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
         height: height,
         width: width,
         padding: padding,
         //height: 400,
         //width: double.infinity,
         decoration: BoxDecoration(
           
           color: dark? darkcolor.withValues(alpha: 0.1): lightcolor.withValues(alpha:  0.1),
           borderRadius: BorderRadius.circular(borderRadius),
           border: Border.all(color:dark? borderColorDark.withValues(alpha: 0.2) : borderColorLight.withValues(alpha: 0.2) ,),
           boxShadow: [
    
             BoxShadow(
    
            color: Colors.black.withValues(alpha:  0.1),
          blurRadius: 10,
          spreadRadius: 2,
            offset: const Offset(0, 4),
           ),
            ],
         ),
         child: child,
        ),
      ),
    );
  }
}