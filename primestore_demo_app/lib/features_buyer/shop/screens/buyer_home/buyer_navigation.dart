


import 'package:demo_project/features/shop/screens/home/widgets/liquid%20glass%20nav%20bar.dart';
import 'package:demo_project/features_buyer/personlization/screens/settings/buyer_setting.dart';

import 'package:demo_project/features_buyer/shop/screens/buyer_home/buyer_home.dart';
import 'package:demo_project/features_buyer/shop/screens/buyer_rides/buyer_rides.dart';
import 'package:demo_project/utils/constants/colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// LiquidGlassNavBar, LiquidGlassNavItem

class BuyerNavigation extends StatelessWidget {
  const BuyerNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    //final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      // Lets the screen content show through the frosted glass bar.
      extendBody: true,
      bottomNavigationBar: LiquidGlassNavBar(
        controller: controller,
        accentColor: TColors.primary,
        items: const [
          LiquidGlassNavItem(icon: Iconsax.home, label: 'Home'),
          LiquidGlassNavItem(icon: Iconsax.calendar, label: 'Rides'),
          LiquidGlassNavItem(icon: Iconsax.user, label: 'Account'),
        ],
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends LiquidGlassNavController {
  final screens = [
    const BuyerHomeScreen(),
    const BuyerRidesScreen(),
    const BuyerSettingsScreen(),
  ];
}
