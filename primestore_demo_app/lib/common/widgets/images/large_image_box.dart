import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';




class TLargeImage extends StatelessWidget {
  const TLargeImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[ Container(
        height: 230,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
         
          borderRadius: BorderRadius.circular(TSizes.borderRadiusXxl + 10),
        ),
        child: Column(
          children: [
            Image.asset(
              TImages.productImage1,
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
              
            ),
          ],
        ),
        
      ),
      Positioned(
        bottom: 20,
        left: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                'Tonight',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.apply(fontSizeDelta: TSizes.xs + 2),
              ),
              Text(
                'Ember',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.apply(fontSizeDelta: TSizes.xs + 2),
              ),
              Text(
                'wood-fired pizza 18-25 min free',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.apply(fontSizeDelta: TSizes.xs ),
              )
        ],
      ))
      ]
    );
  }
}