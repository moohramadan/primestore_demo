import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/features/shop/controllers/cart_controller.dart';
import 'package:demo_project/features/shop/controllers/product_detail_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<ProductDetailController>(
      tag: product.id.toString(),
    );
    final cart = Get.find<CartController>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: Obx(() {
        final variant = controller.selectedVariant.value;
        final unavailable = variant == null; // color/size combo doesn't exist
        final outOfStock = !unavailable && variant.stock <= 0;
        final busy = !unavailable && cart.busyVariantIds.contains(variant.id);
        final disabled = unavailable || outOfStock || busy;

        final label = unavailable
            ? 'Unavailable'
            : outOfStock
                ? 'Out of Stock'
                : busy
                    ? 'Adding...'
                    : 'Add to Cart';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: controller.decrement,
                  child: const TCircularIcon(
                    icon: Iconsax.minus,
                    backgroundColor: TColors.darkGrey,
                    width: 40,
                    height: 40,
                    color: TColors.white,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(
                  '${controller.quantity.value}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                GestureDetector(
                  onTap: controller.increment,
                  child: const TCircularIcon(
                    icon: Iconsax.add,
                    backgroundColor: TColors.black,
                    width: 40,
                    height: 40,
                    color: TColors.white,
                  ),
                ),
              ],
            ),
            TRoundedElevatedButton(
              width: null,
              borderRadius: TSizes.borderRadiusLg,
              onPressed: disabled
                  ? null
                  : () async {
                      final qty = controller.quantity.value;
                      final ok = await cart.addToCart(variant.id, quantity: qty);
                      if (ok) Get.snackbar('Cart', '${qty}x added to cart');
                    },
              padding: const EdgeInsets.all(TSizes.md),
              color: disabled ? TColors.darkGrey : TColors.black,
              borderColor: disabled ? TColors.darkGrey : TColors.black,
              text: label,
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium!.apply(color: TColors.white),
            ),
          ],
        );
      }),
    );
  }
}