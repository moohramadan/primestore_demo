import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TTextFieldRounded extends StatelessWidget {
  const TTextFieldRounded({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.icon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSaved,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.fillColor,
    this.textColor,
    this.hintTextStyle,
    this.labelStyle,
    this.borderColor,
    this.focusedBorderColor,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final Color? textColor;
  final TextStyle? hintTextStyle;
  final TextStyle? labelStyle;
  final Color? borderColor;
  final Color? focusedBorderColor;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final effectiveFillColor = fillColor ?? (dark ? TColors.black : Colors.white);
    final effectiveTextColor = textColor ?? (dark ? Colors.white : Colors.black87);
    final effectiveBorderColor = borderColor ?? (dark ? TColors.dark : TColors.dark);
    final effectiveFocusedBorderColor = focusedBorderColor ?? effectiveBorderColor;

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onSaved: onSaved,
      style: TextStyle(fontSize: 16, color: effectiveTextColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintTextStyle ??
            TextStyle(
              color: dark ? TColors.grey : TColors.darkerGrey,
              fontSize: 12,
            ),
        labelText: labelText,
        labelStyle: labelStyle ??
            TextStyle(
              color: TColors.primary,
              fontWeight: FontWeight.w600,
            ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: icon != null ? Icon(icon, color: TColors.primary) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: effectiveFillColor,
        contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color.fromARGB(255, 164, 23, 23), width: 1.5),
        ),
      ),
    );
  }
}

