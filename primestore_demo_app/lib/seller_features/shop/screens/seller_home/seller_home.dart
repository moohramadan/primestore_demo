import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/shop/screens/seller_home/widgets/seller_categories.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: dark? TColors.white: TColors.black,)
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:  TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: TSizes.spaceBtwSections ,),
            Text('Today', style: Theme.of(context).textTheme.bodyMedium,),
            //SizedBox(height: TSizes.xs,),
            TSectionHeading(title: '\$2,750.00', showActionButton: false, fontsize: 30, fontWeightDelta: 2,),
            SizedBox(height: TSizes.spaceBtwItems,),
            TSellerCategories(),
            SizedBox(height: TSizes.spaceBtwItems,),
            TSectionHeading(title: 'Needs attention', buttonTitle: 'Review', buttonFontSize: 15, textButtonColor: TColors.primary,)
            
          ],
        ),
      ),
    );
  }
}