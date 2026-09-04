import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TGlassContainermd extends StatelessWidget {
  const TGlassContainermd({
    super.key,
    this.lightColor = TColors.white,
    this.borderColorLight = TColors.white,
    this.width = 180,
    required this.icon,
    required this.text,
    required this.subText,
  });

  final Color lightColor;
  final Color borderColorLight;
  final double width;
  final IconData icon;
  final String text;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return TGlassMorphism(
      lightcolor: lightColor,
      borderColorLight: borderColorLight,
      padding: EdgeInsets.all(TSizes.md),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TGlassMorphism(
            lightcolor: lightColor,
            borderColorLight: borderColorLight,
            borderRadius: 10,
            padding: EdgeInsets.all(TSizes.sm),
            child: Icon(icon),
          ),
          SizedBox(height: TSizes.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: 6),
          ),
          SizedBox(height: TSizes.sm),
          Text(
            subText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
