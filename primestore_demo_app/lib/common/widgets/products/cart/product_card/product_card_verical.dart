
import 'package:demo_project/common/styles/shadow_style.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () {},
        // Handle product card tap
      
      child: Container(
        width: 200,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          boxShadow: [TShadowStyle.verticalProductShadow],
          color: dark ? TColors.darkGrey : TColors.white,
        ),
        child: Column(
          children: [
            /// Thumbnail, Wishlist button, Discount tag
           
            TRoundedContainer(
              height:120 ,
              padding: EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.white,
              child: Stack(
                children: [
                  /// thumbnail image
                  TRoundedImage(
                    imageUrl: TImages.productImage1,
      
                    applyImageRadius: true,
                  ),
      
                  /// sale tag
                  Positioned(
                    top: 0,
                    child: TRoundedContainer(
                      radius: TSizes.sm,
                      backgroundColor: TColors.secondary.withValues(alpha: 0.8),
      
                      padding: EdgeInsets.symmetric(
                        horizontal: TSizes.sm,
                        vertical: TSizes.xs,
                      ),
                      child: Text(
                        '25%',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge!.apply(color: TColors.black),
                      ),
                    ),
                  ),
      
                  /// -- Favourite Icon Button
                  Positioned(
                    right: 0,
                    top: 0,
                    child: TCircularIcon(icon: Iconsax.heart5, color: Colors.red),
                  ),
                ],
              ),
            ),
           SizedBox(height: TSizes.spaceBtwItems / 2,),
            ///Details
            Padding(
              padding: const EdgeInsets.all(TSizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TProductTitleText(title: 'Green Nike Air Max 270 React ENG', ),
                  SizedBox(height: TSizes.spaceBtwItems / 2,),
                  Row(
                  children: [
                   Text(
                  'Nike',
                  overflow: TextOverflow.ellipsis,
                 maxLines: 1,
                style: Theme.of(context).textTheme.labelMedium,
                ),
               const SizedBox(width: TSizes.xs),
              const Icon(
               Iconsax.verify5,
                 color: TColors.primary,
               size: TSizes.iconXs,
               ),
                 ],
               ),
                  /// Add Spacer() here to keep the height each box same in case 1 or 2 lines of heading
                  const SizedBox(height: TSizes.spaceBtwItems,),
                ],
              ),
            ),
            const Spacer(),

                  /// Price and Add to Cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: TSizes.sm),
                        child: TProductPriceText(price: '35.00', ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: TColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusMd),
                            bottomRight: Radius.circular(TSizes.productImageRadius),
                          ),
                        ),
                        child: SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(child: Icon(Iconsax.add, color: TColors.white,))),
                      ),
                      
                      
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}



