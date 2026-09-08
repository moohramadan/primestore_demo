import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TGlassVerticalCard extends StatelessWidget {
  const TGlassVerticalCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final variant = product.defaultVariant;
    final imageUrl = product.mainImageUrl;

    final price = variant?.price ?? 0;
    final discountPercent = variant?.discountPercent ?? 0;
    final originalPrice = discountPercent > 0
        ? price / (1 - discountPercent / 100)
        : price;

    return Stack(
      children: [
        TGlassMorphism(
          borderRadius: 10,
          width: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 150,
                      child: imageUrl == null
                          ? const Icon(Iconsax.gallery_slash)
                          : (imageUrl.startsWith('http')
                              ? Image.network(imageUrl, height: 80, width: double.infinity, fit: BoxFit.contain)
                              : Image.asset(imageUrl, height: 80, width: double.infinity, fit: BoxFit.contain)),
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
                          const SizedBox(width: TSizes.xs),
                          Row(
                            children: [
                              TProductPriceText(price: price.toStringAsFixed(0), isLarge: false),
                              if (discountPercent > 0) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '\$${originalPrice.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleSmall!.apply(
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
            ],
          ),
        ),
        if (discountPercent > 0)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: TColors.buttonPrimary,
              ),
              padding: const EdgeInsets.all(7),
              child: Text('$discountPercent%'),
            ),
          ),
        const Positioned(
          top: 10,
          right: 10,
          child: TGlassMorphism(child: Icon(Iconsax.heart, color: Colors.red)),
        ),
      ],
    );
  }
}

