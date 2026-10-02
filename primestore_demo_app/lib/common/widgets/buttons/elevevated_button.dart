import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TRoundedElevatedButton extends StatelessWidget {
  const TRoundedElevatedButton({
    super.key,
    this.color = TColors.primary,
    required this.onPressed,
    required this.text,
    this.icon,
    this.width = double.infinity,
    this.height,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.elevation,
  });

  final Color color;
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final buttonText = Text(
      text,
      style:
          textStyle ??
          Theme.of(context).textTheme.headlineSmall!.apply(
            color: TColors.white,
            fontWeightDelta: 28,
          ),
    );

    final buttonChild = icon == null
        ? buttonText
        : SizedBox(
            width: width ?? double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: TSizes.lg),
                const SizedBox(width: 10),
                buttonText,
              ],
            ),
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: borderColor == null ? null : BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          elevation: elevation,
        ),
        child: buttonChild,
      ),
    );
  }
}
