import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/texts/product_title_text.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TGlassVerticalCard extends StatelessWidget {
  const TGlassVerticalCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                     borderRadius: BorderRadius.circular(10)
                    ),
                    height: 150,
                    
                    child: Image(image: AssetImage(TImages.productImage3,), height: 80, width: double.infinity,),
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
            ),],
               ),
              
             ),
            ],
          ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: TColors.buttonPrimary
            ),
             padding: EdgeInsets.all(7), 
             child: Text('23%'),)
             ),
             Positioned(
            top: 10,
            right: 10,
            child: TGlassMorphism(child: Icon(Iconsax.heart, color: Colors.red,))
             ),       
      ],
    );
  }
}