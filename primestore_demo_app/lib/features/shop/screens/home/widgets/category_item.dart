import 'dart:ui';

import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TCategoryItem extends StatelessWidget {
  const TCategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: isSelected 
                  ? TColors.primary.withValues(alpha: 0.2) 
                  : TColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: isSelected 
                  ? Border.all(color: TColors.primary, width: 1.5) 
                  : Border.all(color: TColors.white.withValues(alpha: 0.2) ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4)
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? TColors.primary : null,
                  ),
                  const SizedBox(height: TSizes.md - 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? TColors.primary : null,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TCategoryBuilder extends StatelessWidget {
  const TCategoryBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: 90, // important so ListView has a height
    child: ListView(
           scrollDirection: Axis.horizontal,
           children: [
          TCategoryItem(
    icon: Iconsax.element_4,
    title: 'All',
    isSelected: false,
    onTap: () {},
          ),
          const SizedBox(width: 12),
    
          TCategoryItem(
    icon: Iconsax.headphone,
    title: 'Audio',
    onTap: () {},
          ),
          const SizedBox(width: 12),
    
          TCategoryItem(
    icon: Iconsax.watch,
    title: 'Wearables',
    onTap: () {},
          ),
          const SizedBox(width: 12),
    
          TCategoryItem(
    icon: Iconsax.safe_home,
    title: 'Footwear',
    onTap: () {},
          ),
          const SizedBox(width: 12),
    
          TCategoryItem(
    icon: Iconsax.shop,
    title: 'Fashion',
    onTap: () {},
          ),
        ],
      ),
    );
  }
}

