import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TTextfiedRounded extends StatelessWidget {
  const  TTextfiedRounded({
    super.key,
     required this.labeltext, required this.hinttext, required this.icon,
  });

  
  final String labeltext,hinttext;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
   final dark = THelperFunctions.isDarkMode(context);
    return TextFormField(
    
    keyboardType: TextInputType.emailAddress,
    
    style:  TextStyle(fontSize: 16, color: Colors.black87),
    decoration: InputDecoration(
      hintText: hinttext,
      hintStyle: TextStyle(color: dark? TColors.grey : TColors.darkerGrey, fontSize: 12),
      labelText: labeltext,
      labelStyle: TextStyle(
        color: TColors.primary,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always, // keeps label on top
      prefixIcon: Icon(icon, color:  dark? TColors.primary: TColors.primary,),
      filled: true,
      fillColor: dark? Color.fromRGBO(20, 25, 39, 1):Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50), // ← pill shape
        borderSide: BorderSide(color: dark? TColors.secondaryDark:TColors.secondary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: dark? TColors.secondaryDark:TColors.secondary,width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: dark? TColors.secondaryDark:TColors.secondary,width: 1.5),
      ),
      // Optional: remove the default error border style if you want
    ),
      );
  }
}