import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';



class TRoundImage extends StatelessWidget {
  const TRoundImage({
    super.key,
    this.imageUrl = 'assets/images/user/passport.png',
    this.width = TSizes.iconLg + TSizes.md,
    this.height = TSizes.iconLg + TSizes.md,
    this.padding = EdgeInsets.zero,
    this.borderRadius = TSizes.borderRadiusXxl,
    this.backgroundColor,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (dark ? TColors.darkerGrey : TColors.grey),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(imageUrl, width: width, height: height, fit: fit),
      ),
    );
  }
}
