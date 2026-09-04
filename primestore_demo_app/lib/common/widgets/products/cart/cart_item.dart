
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/common/widgets/texts/t_brand_title_text_with_verification_icon.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TCartItem extends StatelessWidget {
  const TCartItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TRoundedImage(
          imageUrl: TImages.productImage1,
          width: 60,
          height: 60,
          padding: EdgeInsets.all(TSizes.sm),
          backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.darkGrey:TColors.light,
          ),
          SizedBox(width :TSizes.spaceBtwItems),
    
          ///Title, price & size
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TBrandTitleWithVerifiedIcon(title: 'Nike'),
                Flexible(child: TProductTitleText(title: 'Black Sport Shoes bgvbhgvfcgfvcdvghfvcvbghfcvbghfcdvbghfc', maxLines: 1,)),
                ///Attributes
                Text.rich(TextSpan(
                  children: [
                    TextSpan(text: 'Color', style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(text: 'Green', style: Theme.of(context).textTheme.bodyLarge),
                    TextSpan(text: 'Size', style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(text: 'UK 08', style: Theme.of(context).textTheme.bodyLarge),
                  ]
                ))
              ],
            ),
          )
      ],
    );
  }
}