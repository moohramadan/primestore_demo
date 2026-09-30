import 'package:demo_project/common/widgets/images/round_image.dart';
import 'package:demo_project/common/widgets/texts/rounded_text.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class SellerProductDetail extends StatelessWidget {
  const SellerProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyActions: true,
        actions: [
         Padding(
           padding: const EdgeInsets.only(right:  TSizes.md),
           child: TRoundedText(text: 'edit', height: 40, width: 70,),
         ) ,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            
            TRoundImage(
              imageUrl: TImages.productImage1,
              height: 230,
              width: double.infinity,
            ),
            SizedBox(height: TSizes.spaceBtwItems,),
            TSectionHeading(title: 'Product details', showActionButton: false,)
          ],
        ),
      ),
    );
  }
}