import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/product_info.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyActions: true,
        titleSpacing: TSizes.md * 6,
        title: Text('Add product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TSectionHeading(title: 'Photos', showActionButton: false,),
                Text('1 of 6',style:  Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SizedBox(height : TSizes.spaceBtwInputFields),
            Row(
              children: [
                TRoundedContainer(
                  height: 100,
                  width: 100,
                  backgroundColor:dark? TColors.darkerGrey : TColors.grey,
                  child: Icon(Iconsax.gallery, size: TSizes.xl + 5,),
                  ),
                  SizedBox(width : TSizes.spaceBtwInputFields),
                  TRoundedContainer(
                  height: 100,
                  width: 100,
                  backgroundColor:dark? TColors.darkerGrey : TColors.grey,
                  child: Icon(Iconsax.add, size: TSizes.xl + 5,),
                  ),
                  SizedBox(width : TSizes.spaceBtwInputFields),
                  TRoundedContainer(
                  height: 100,
                  width: 100,
                  backgroundColor:dark? TColors.darkerGrey : TColors.grey,
                  child: Icon(Iconsax.add, size: TSizes.xl + 5,),
                  )
              ],
            ),
            SizedBox(height : TSizes.spaceBtwInputFields),
            TSectionHeading(title: "Product Info", showActionButton: false, ),
            SizedBox(height : TSizes.spaceBtwInputFields),
            ProductInfoContainer()
          ],
        ),
      ),
    );
  }
}