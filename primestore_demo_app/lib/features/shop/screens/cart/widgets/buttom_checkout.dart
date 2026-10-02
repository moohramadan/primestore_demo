import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/shop/screens/cart/cart.dart';
import 'package:demo_project/features/shop/screens/checkout/checkout.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';
class TBottomCheckot extends StatelessWidget {
  const TBottomCheckot({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      //height: 120,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TSectionHeading(title: '\$90.00', showActionButton: false, fontsize: 10,),
          SizedBox(
            height: 60, width: 140,
            child: TRoundedElevatedButton(onPressed: () => Get.to(() => CheckoutScreen()), text: 'checkout', borderRadius: TSizes.borderRadiusXxl, color: TColors.black, borderColor: TColors.black,))

          
        ],
      )
    );
  }
}