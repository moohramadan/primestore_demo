import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';



/// Dark mode background — blue glow bleeding in from the top,
/// fading to black. Same effect as the reference, blue instead of green.
class TAppBackgroundDark extends StatelessWidget {
  const TAppBackgroundDark({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.9), // glow origin, top-left-ish
            radius: 1.4,
            colors: [
              TColors.brand.withValues(alpha:  0.55),
              TColors.brand.withValues(alpha:  0.15),
              Colors.black,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Light mode background — white body, with the brand blue only
/// visible as a soft bleed at the edges/corners.
class TAppBackgroundLight extends StatelessWidget {
  const TAppBackgroundLight({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRRect(
        child: Stack(
          children: [
            // Base white body
            Container(color: Colors.white),
        
            // Soft blue glow bleeding in from the corners
            Positioned(
              top: -100,
              left: -100,
              child: _glowCircle(),
            ),
            Positioned(
              top: -100,
              right: -100,
              child: _glowCircle(),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _glowCircle(size: 260),
            ),
            
            
        
            // Content on top
            ?child,
          ],
        ),
      ),
    );
  }

  Widget _glowCircle({double size = 300}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            TColors.brand.withValues(alpha:  0.35),
            TColors.brand.withValues(alpha:  0.0),
          ],
        ),
      ),
    );
  }
}
