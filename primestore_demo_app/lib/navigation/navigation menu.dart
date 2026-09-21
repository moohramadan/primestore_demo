import 'package:demo_project/features/personalization/screens/setting/setting.dart';
import 'package:demo_project/features/shop/screens/home/home.dart';
import 'package:demo_project/navigation/widgets/liquid%20glass%20nav%20bar.dart';
import 'package:demo_project/features/shop/screens/wishlist/wishlist.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// LiquidGlassNavBar, LiquidGlassNavItem

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

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
          LiquidGlassNavItem(icon: Iconsax.shop, label: 'Store'),
          LiquidGlassNavItem(icon: Iconsax.heart, label: 'Wishlist'),
          LiquidGlassNavItem(icon: Iconsax.user, label: 'Profile'),
        ],
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends LiquidGlassNavController {
  final screens = [
    const HomeScreen(),
    const Center(child: Text('Store')),
    const WishlistScreen(),
    const SettingsScreen(),
  ];
}
