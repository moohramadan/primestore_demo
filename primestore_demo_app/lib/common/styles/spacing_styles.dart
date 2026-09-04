import 'package:demo_project/utils/constants/sizes.dart';

import 'package:flutter/material.dart';

class TSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    bottom: TSizes.defaultSpace,
    right: TSizes.defaultSpace,
    left: TSizes.defaultSpace,
    top: TSizes.appBarHeight
  );
 
}
 class TSpacingStyle2 {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    bottom: TSizes.defaultSpace * 2,
    right: TSizes.defaultSpace * 2,
    left: TSizes.defaultSpace * 2,
    top: TSizes.appBarHeight * 2,
  );
 }