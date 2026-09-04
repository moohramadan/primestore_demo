
import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TProductQuantityWithAddAndRemoveButton extends StatelessWidget {
  const TProductQuantityWithAddAndRemoveButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
     mainAxisSize: MainAxisSize.min,
      children: [
        TCircularIcon(
         icon: Iconsax.minus,
         width: 32,
         height: 32,
         size: TSizes.md,
         color: THelperFunctions.isDarkMode(context)? TColors.white: TColors.black,
         backgroundColor: THelperFunctions.isDarkMode(context)? TColors.darkGrey: TColors.white,
         ),
          SizedBox(width: TSizes.spaceBtwItems,),
       Text('2', style: Theme.of(context).textTheme.titleSmall,),
     SizedBox(width: TSizes.spaceBtwItems,),
      TCircularIcon(
     icon: Iconsax.add,
     width: 32,
     height: 32,
     size: TSizes.md,
     color:  TColors.white,
     backgroundColor:  TColors.primary,
     ),
      ],
    );
  }
}

