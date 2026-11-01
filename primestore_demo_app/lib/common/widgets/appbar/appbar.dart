
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/device/device_utility.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Reusable application AppBar with configurable title, actions and leading
// icon. Implements PreferredSizeWidget so it can be used directly as an
// AppBar in Scaffold.appBar.
class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
  });

  // Optional title widget (can be Text or any Widget)
  final Widget? title;
  // If true, shows a default back arrow that calls `Get.back()`
  final bool showBackArrow;
  // Optional leading icon shown when `showBackArrow` is false
  final IconData? leadingIcon;
  // Optional list of action widgets displayed at the end of the AppBar
  final List<Widget>? actions;
  // Optional callback for the custom leading icon
  final VoidCallback? leadingOnPressed;
 

  @override
  Widget build(BuildContext context) {
  
    final dark = THelperFunctions.isDarkMode(context);
    // Wrap the AppBar with horizontal padding for consistent spacing
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      child: AppBar(
        
        automaticallyImplyLeading: false,
        // Leading logic: prefer explicit back arrow, otherwise use custom
        // leading icon if supplied.
        leading: showBackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Iconsax.arrow_left),
                color: dark? TColors.dark: TColors.dark,
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(leadingIcon),
                  )
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  // Preferred size uses device utility to match platform status/app bar height
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}