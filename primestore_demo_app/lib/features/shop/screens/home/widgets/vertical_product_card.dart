import 'package:demo_project/common/widgets/icons/wislist_icon.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TVerticalProductCard extends StatelessWidget {
  const TVerticalProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final variant = product.defaultVariant;
    final imageUrl = product.mainImageUrl;
    final price = variant?.effectivePrice ?? 0;
    final discountPercent = variant?.discountPercent ?? 0;
    final originalPrice = variant?.price ?? price;
    final borderRadius = BorderRadius.circular(TSizes.borderRadiusMd);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: borderRadius,
            border: Border.all(color: TColors.borderSecondary),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                  ),
                  height: 150,
                  child: imageUrl == null
                      ? const Icon(Iconsax.gallery_slash)
                      : (imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                imageUrl,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              )),
                ),
                SizedBox(height: TSizes.spaceBtwItems / 2),
                Padding(
                  padding: const EdgeInsets.all(TSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TProductTitleText(title: product.name),
                      SizedBox(height: TSizes.spaceBtwItems / 2),
                      Row(
                        children: [
                          Text(
                            product.brandName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: TSizes.xs),
                          if (product.brandVerified)
                            const Icon(
                              Iconsax.verify5,
                              color: TColors.primary,
                              size: TSizes.iconXs,
                            ),
                        ],
                      ),
                      const SizedBox(height: TSizes.xs),
                      Row(
                        children: [
                          TProductPriceText(
                            price: price.toStringAsFixed(2),
                            isLarge: false,
                          ),
                          if (variant?.isOnSale ?? false) ...[
                            const SizedBox(width: 10),
                            Text(
                              TCurrency.format(originalPrice),
                              style: Theme.of(context).textTheme.titleSmall!
                                  .apply(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (discountPercent > 0)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                color: Colors.amberAccent,
              ),
              padding: const EdgeInsets.all(7),
              child: Text(
                '$discountPercent%',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.apply(color: TColors.black),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: WishlistIconButton(product: product),
        ),
      ],
    );
  }
}
