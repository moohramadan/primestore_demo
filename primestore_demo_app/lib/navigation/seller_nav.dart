import 'package:demo_project/seller_features/personalization/screens/seller_setting/seller_setting.dart';
import 'package:demo_project/seller_features/shop/screens/seller_catalogue/seller_catalogue.dart';
import 'package:demo_project/seller_features/shop/screens/seller_home/seller_home.dart';
import 'package:demo_project/seller_features/shop/screens/seller_orders/seller_orders.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SellerNavigationMenu extends StatefulWidget {
  const SellerNavigationMenu({super.key});

  @override
  State<SellerNavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<SellerNavigationMenu> {
  int selectedIndex = 0;

  final screens = const [
    SellerHomeScreen(),
    SellerCatalogueScreen(),
    SellerOrdersScreen(),
    SellerSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Color.fromRGBO(102, 110, 122, 0.2)
                : TColors.white,
            indicatorColor: TColors.primary.withValues(alpha: 0.14),
            destinations: const [
              NavigationDestination(
                icon: Icon(Iconsax.home_2),
                selectedIcon: Icon(Iconsax.home_25),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.production_quantity_limits),
                label: 'Catalogue',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.receipt_item),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.profile_circle),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
