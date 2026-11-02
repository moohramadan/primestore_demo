//import 'package:demo_project/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:demo_project/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height = 400,
    this.color = TColors.primary,
  });

  final Widget child;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgesWidget(
      child: Container(
        height: height,
        color: color,
        padding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _HeaderCircle(
                size: 230,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              top: 150,
              left: -110,
              child: _HeaderCircle(
                size: 220,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -125,
              right: 35,
              child: _HeaderCircle(
                size: 250,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
