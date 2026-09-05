import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

/// Reusable frosted input field styled to sit inside a TGlassMorphism card.
/// Stateless by design — obscure/trailing-icon behavior is driven by the
/// parent via ValueListenableBuilder rather than internal state.
class GlassTextField extends StatelessWidget {
  final bool dark;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final TextEditingController? controller;

  const GlassTextField({
    super.key,
    required this.dark,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.trailingIcon,
    this.onTrailingTap,
    this.controller,
  });


  @override
  Widget build(BuildContext context) {
    final labelColor = dark ? Colors.white.withValues(alpha: 0.6) :  Color(0xFF5E6784);
    final iconColor = dark ? Colors.white.withValues(alpha: 0.5) : TColors.primary;
    final textColor = dark ? Colors.white : const Color(0xFF1A2033);
    final borderColor = dark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.8);
    final fillColor = dark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  obscureText: obscure,
                  controller: controller,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: InputDecoration(
                    hintText: hint,
                    label: Text(label),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintStyle: TextStyle(fontSize: 14, color: labelColor),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (trailingIcon != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Icon(trailingIcon, size: 18, color: iconColor),
                ),
            ],
          ),
        ),
      ],
    );
  }
}