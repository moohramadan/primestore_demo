import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/cards/vertical_cart_card.dart';
import 'package:demo_project/features/shop/screens/cart/widgets/buttom_checkout.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: TBottomCheckot(),
      appBar: AppBar(
        title: Text('Cart', style: Theme.of(context).textTheme.headlineMedium),
        titleSpacing: 120,
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: TGlassMorphism(
            padding: EdgeInsets.all(0),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Iconsax.arrow_left,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.sm,
          vertical: TSizes.defaultSpace,
        ),
        child: Column(
          children: [
            THorizontalCartCard(dark: dark),
            SizedBox(height: TSizes.spaceBtwItems),
            THorizontalCartCard(dark: dark),
            SizedBox(height: TSizes.spaceBtwInputFields),
          ],
        ),
      ),
    );
  }
}
