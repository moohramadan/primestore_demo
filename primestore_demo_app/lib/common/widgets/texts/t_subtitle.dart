import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TSubtitle extends StatelessWidget {
  const TSubtitle({
    super.key,
    required this.title,
    this.textColor,
    this.fontSize = TSizes.md,
    this.maxLines,
    this.textAlign,
  });

  final String title;
  final Color? textColor;
  final double? fontSize;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor ?? (isDark ? TColors.grey : const Color.fromARGB(255, 91, 91, 91)),
            fontSize: fontSize,
          ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}