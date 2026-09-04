import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CTextfield extends StatelessWidget {
  const CTextfield({
    super.key,
    required this.dark, required this.labelText, required this.hintText, required this.icon,
  });

  final bool dark;
  final String labelText;
  final String hintText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
     decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: dark? TColors.darkGrey : TColors.darkerGrey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelText: labelText,
      prefixIcon: Icon(icon, color: TColors.primary,),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
       borderRadius: BorderRadius.circular(50),
       borderSide: BorderSide(color: TColors.secondary),
      ),
       enabledBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(50),
       borderSide: BorderSide(color: TColors.secondary),
      ),
      focusedBorder: OutlineInputBorder(
       borderRadius: BorderRadius.circular(50),
       borderSide: BorderSide(color: TColors.secondary),
      ),
    
     ),
    );
  }
}