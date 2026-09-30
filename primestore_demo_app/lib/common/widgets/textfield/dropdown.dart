import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TDropdownField<T> extends StatelessWidget {
  const TDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.labelText,
    this.hintText,
    this.icon,
    this.validator,
    this.enabled = true,
    this.borderRadius = 24,
    this.fillColor,
    this.decoration,
    this.isExpanded = true,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final double borderRadius;
  final Color? fillColor;
  final InputDecoration? decoration;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final effectiveFillColor = fillColor ?? (dark ? TColors.black : Colors.white);
    final borderColor = dark ? TColors.dark : TColors.dark;

    final defaultDecoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: icon != null ? Icon(icon, color: TColors.primary) : null,
      filled: true,
      fillColor: effectiveFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(
        
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: dark ? TColors.grey : TColors.darkerGrey,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
    );

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      decoration: decoration ?? defaultDecoration,
      icon: const Icon(Icons.arrow_drop_down, color: TColors.primary),
      dropdownColor: effectiveFillColor,
      style: TextStyle(
        fontSize: 16,
        color: dark ? Colors.white : Colors.black87,
      ),
    );
  }
}

// Example usage:
// TDropdownField<String>(
//   labelText: 'Gender',
//   hintText: 'Select gender',
//   value: 'Male',
//   items: const [
//     DropdownMenuItem(value: 'Male', child: Text('Male')),
//     DropdownMenuItem(value: 'Female', child: Text('Female')),
//   ],
//   onChanged: (value) {},
// );