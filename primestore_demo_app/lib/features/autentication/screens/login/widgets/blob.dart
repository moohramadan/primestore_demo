import 'package:flutter/material.dart';


class Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double? blurRadius;
  final double? spreadRadius;

  const Blob({
    super.key,
    required this.color,
    required this.opacity,
    required this.size,
    this.blurRadius = 80,
    this.spreadRadius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blurRadius!,
            spreadRadius: spreadRadius!,
          ), // BoxShadow
        ],
      ), // BoxDecoration
    ); // Container
  }
}