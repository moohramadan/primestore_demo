
import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/features/shop/controllers/product_detail_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<ProductDetailController>(tag: product.id.toString());

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
      child: Obx(() => Row(
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
                  Text('${controller.quantity.value}', style: Theme.of(context).textTheme.titleSmall),
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
              ElevatedButton(
                onPressed: controller.isOutOfStock ? null : () {
                  // cart backend not built yet — placeholder for now
                  Get.snackbar('Added', '${controller.quantity.value}x added to cart');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(TSizes.md),
                  backgroundColor: controller.isOutOfStock ? TColors.darkGrey : TColors.black,
                  side: BorderSide(color: controller.isOutOfStock ? TColors.darkGrey : TColors.black),
                ),
                child: Text(controller.isOutOfStock ? 'Out of Stock' : 'Add to Cart'),
              ),
            ],
          )),
    );
  }
}
