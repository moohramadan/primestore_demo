
import 'package:demo_project/features/shop/controllers/product_detail_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/images/t_circular_image.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/common/widgets/texts/t_brand_title_text_with_verification_icon.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/enums.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:get/get.dart';

class TProductMetaData extends StatelessWidget {
  const TProductMetaData({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    final controller = Get.find<ProductDetailController>(tag: product.id.toString());

    return Obx(() {
      final variant = controller.selectedVariant.value;
      final price = variant?.effectivePrice ?? 0;
      final discountPercent = variant?.discountPercent ?? 0;
      final originalPrice = variant?.price ?? price;
      final inStock = (variant?.stock ?? 0) > 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Price & Sale Price
          Row(
            children: [
              if (discountPercent > 0) ...[
                TRoundedContainer(
                  radius: TSizes.sm,
                  backgroundColor: TColors.secondary.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
                  child: Text(
                    '$discountPercent%',
                    style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.black),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
              ],
              if (variant?.isOnSale ?? false) ...[
                Text(
                  TCurrency.format(originalPrice),
                  style: Theme.of(context).textTheme.titleSmall!.apply(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
              ],
              TProductPriceText(price: price.toStringAsFixed(2), isLarge: true),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),

          /// Title
          TProductTitleText(title: product.name),
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),

          /// Stock Status
          Row(
            children: [
              const TProductTitleText(title: 'Status'),
              const SizedBox(width: TSizes.spaceBtwItems),
              Text(
                inStock ? 'In Stock' : 'Out of Stock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),

          /// Brand
          Row(
            children: [
              TCircularImage(
                image: TImages.brandImage1, // static placeholder — no brand logo URL wired yet
                width: 32,
                height: 32,
                overlayColor: darkMode ? TColors.black : TColors.black,
              ),
              TBrandTitleWithVerifiedIcon(
                title: product.brandName,
                brandTextSize: TextSizes.medium,
              ),
            ],
          ),
        ],
      );
    });
  }
}
