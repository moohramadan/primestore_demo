import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/cards/vertical_cart_card.dart';
import 'package:demo_project/features/shop/controllers/cart_controller.dart';
import 'package:demo_project/features/shop/screens/cart/widgets/buttom_checkout.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<CartController>();

    return Scaffold(
      bottomNavigationBar: const TBottomCheckot(),
      appBar: AppBar(
        title: Text('Cart', style: Theme.of(context).textTheme.headlineMedium),
        titleSpacing: 120,
        leading: Padding(
          padding: const EdgeInsets.all(5),
          child: TGlassMorphism(
            padding: const EdgeInsets.all(0),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Iconsax.arrow_left,
                color: dark ? TColors.white : TColors.black,
              ),
            ),
          ),
        ),
        actions: const [
          TGlassMorphism(
            padding: EdgeInsets.all(9),
            child: Icon(Iconsax.shopping_bag),
          ),
        ],
      ),
      body: Obx(() {
        final cart = controller.cart.value;

        // Nothing loaded yet
        if (cart == null) {
          return controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Couldn't load your cart"),
                      const SizedBox(height: TSizes.sm),
                      ElevatedButton(
                        onPressed: controller.fetchCart,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
        }

        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.shopping_bag, size: 64),
                const SizedBox(height: TSizes.md),
                Text(
                  'Your cart is empty',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCart,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.sm,
              vertical: TSizes.defaultSpace,
            ),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (_, i) =>
                THorizontalCartCard(dark: dark, item: cart.items[i]),
          ),
        );
      }),
    );
  }
}