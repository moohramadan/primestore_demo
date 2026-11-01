import 'package:demo_project/common/widgets/chips/choice_chips.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/shop/controllers/product_detail_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TProductAttributes extends StatelessWidget {
  const TProductAttributes({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<ProductDetailController>(
      tag: product.id.toString(),
    );

    return Obx(() {
      final variant = controller.selectedVariant.value;
      final price = variant?.effectivePrice ?? 0;
      final originalPrice = variant?.price ?? price;
      final inStock = (variant?.stock ?? 0) > 0;

      return Column(
        children: [
          /// Selected Attribute pricing and description
          TRoundedContainer(
            padding: const EdgeInsets.all(TSizes.md),
            backgroundColor: dark ? TColors.darkerGrey : TColors.grey,
            child: Column(
              children: [
                Row(
                  children: [
                    const TSectionHeading(
                      title: "Variation",
                      showActionButton: false,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const TProductTitleText(
                              title: 'Price: ',
                              smallSize: true,
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            if (variant?.isOnSale ?? false) ...[
                              Text(
                                TCurrency.format(originalPrice),
                                style: Theme.of(context).textTheme.titleSmall!
                                    .apply(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                            ],
                            TProductPriceText(price: price.toStringAsFixed(2)),
                          ],
                        ),
                        Row(
                          children: [
                            const TProductTitleText(
                              title: 'Stock: ',
                              smallSize: true,
                            ),
                            Text(
                              variant == null
                                  ? 'Unavailable'
                                  : (inStock ? 'In Stock' : 'Out of Stock'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                /// Variation description
                TProductTitleText(
                  title: product.description,
                  maxLines: 4,
                  smallSize: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Colors
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: "Colors", showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Wrap(
                spacing: 8,
                children: controller.availableColors.map((color) {
                  return TChoiceChip(
                    text: color,
                    selected: controller.selectedColor.value == color,
                    onSelected: (_) => controller.selectColor(color),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Sizes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: "Size", showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Wrap(
                spacing: 8,
                children: controller.availableSizes.map((size) {
                  return TChoiceChip(
                    text: size,
                    selected: controller.selectedSize.value == size,
                    onSelected: (_) => controller.selectSize(size),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      );
    });
  }
}
