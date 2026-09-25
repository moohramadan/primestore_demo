import 'package:demo_project/common/widgets/icons/round_icon.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TIconsText extends StatelessWidget {
  const TIconsText({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.textStyle,
    this.iconSize = TSizes.iconLg - 2,
    this.iconPadding = const EdgeInsets.all(15),
    this.iconBorderRadius = TSizes.borderRadiusXxl * 2,
    this.spacing = TSizes.spaceBtwInputFields,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double iconSize;
  final EdgeInsetsGeometry iconPadding;
  final double iconBorderRadius;
  final double spacing;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TRoundedIcon(
          icon: icon,
          iconColor: iconColor,
          padding: iconPadding,
          borderRadius: iconBorderRadius,
          iconSize: iconSize,
        ),
        SizedBox(height: spacing),
        Text(
          text,
          textAlign: textAlign,
          style: textStyle ??
              Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: 2),
        ),
      ],
    );

    return onTap == null
        ? content
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(iconBorderRadius),
            child: content,
          );
  }
}