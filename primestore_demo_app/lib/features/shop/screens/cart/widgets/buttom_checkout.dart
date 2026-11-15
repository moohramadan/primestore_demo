
import 'package:demo_project/features/shop/screens/checkout/checkout.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:demo_project/common/widgets/cards/vertical_cart_card.dart'; // for cartMoney
import 'package:demo_project/features/shop/controllers/cart_controller.dart';
// import your CheckoutScreen

import 'package:get/get.dart';

class TBottomCheckot extends StatelessWidget {
  const TBottomCheckot({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);
    final controller = Get.find<CartController>();

    return Obx(() {
      if (controller.isEmpty) return const SizedBox.shrink();
      final blocked = controller.hasUnavailableItems;

      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              TSizes.md, TSizes.md, TSizes.md, TSizes.sm),
          decoration: BoxDecoration(
            color: dark ? TColors.darkerGrey : TColors.white,
            border: Border(
              top: BorderSide(
                color: dark ? TColors.darkGrey : TColors.borderSecondary,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: TColors.textSecondary)),
                    Text(cartMoney(controller.cart.value!.subtotal),
                        style: theme.textTheme.titleLarge),
                    if (blocked)
                      Text('Some items are out of stock',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      blocked ? null : () => Get.to(() => const CheckoutScreen()),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}