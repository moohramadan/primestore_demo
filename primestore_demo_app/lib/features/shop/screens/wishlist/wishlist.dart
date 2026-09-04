

import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/glass_morphism/vertical_card.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
   final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist', style: Theme.of(context).textTheme.headlineMedium,),
        titleSpacing: 90,
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: TGlassMorphism(
            padding: EdgeInsets.all(0),
            child: Icon(Iconsax.arrow_left, color: dark? TColors.white : TColors.black,),
            ),
        ),
        actions: [
           TGlassMorphism(
             padding: EdgeInsets.all(9),
             child: Icon(Iconsax.shopping_bag),
             ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.defaultSpace),
        child: Column(
          
          children: [
            TVerticalGlassCard(dark: dark),
            SizedBox(height: TSizes.spaceBtwItems,),
            TVerticalGlassCard(dark: dark),
          ],
        ),
      ),
    );
  }
}

