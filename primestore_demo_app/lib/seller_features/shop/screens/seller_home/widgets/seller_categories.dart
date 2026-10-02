import 'dart:ui';

import 'package:demo_project/common/widgets/icons/icons_text.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


class TSellerCategories extends StatelessWidget {
  const TSellerCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: 120, // important so ListView has a height
    child: ListView(
           scrollDirection: Axis.horizontal,
           children: [
          TIconsText(icon: Iconsax.element_4, text: 'All', iconSize: TSizes.iconLg, ),
          const SizedBox(width: 24),

          TIconsText(icon: Iconsax.headphone, text: 'Audio', iconSize: TSizes.iconLg,),
          const SizedBox(width: 24),

          TIconsText(icon: Iconsax.watch, text: 'Wearables', iconSize: TSizes.iconLg,),
          const SizedBox(width: 24),

          TIconsText(icon: Iconsax.safe_home, text: 'Footwear', iconSize: TSizes.iconLg,),
          
        ],
      ),
    );
  }
}

