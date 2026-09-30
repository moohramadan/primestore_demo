import 'package:flutter/material.dart';

class THeadline extends StatelessWidget {
  const THeadline({
    super.key,
    required this.title,
    this.textColor,
    this.fontsize = 8,
    this.fontWeightDelta = 2,
    this.maxLines = 1,
    this.textAlign,
  });

  final String title;
  final Color? textColor;
  final double fontsize;
  final int fontWeightDelta;
  final int maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall!.apply(
            color: textColor,
            fontSizeDelta: fontsize,
            fontWeightDelta: fontWeightDelta,
          ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}