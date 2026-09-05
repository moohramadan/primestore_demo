import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:flutter/material.dart';

/// Small frosted-glass circular button for social login icons.
class SocialGlassButton extends StatelessWidget {
  final bool dark;
  final IconData icon;

  const SocialGlassButton({super.key, required this.dark, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TGlassMorphism(
        padding: const EdgeInsets.symmetric(vertical: 11),
        borderRadius: 14,
        child: Center(
          child: Icon(
            icon,
            size: 19,
            color: dark ? Colors.white : const Color(0xFF1A2033),
          ),
        ),
      ),
    );
  }
}
