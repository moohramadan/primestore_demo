
import 'package:demo_project/common/widgets/icons/icons_text.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


class TCategoryBuilder extends StatelessWidget {
  const TCategoryBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: 100, // important so ListView has a height
    child: ListView(
           scrollDirection: Axis.horizontal,
           children: [
          TIconsText(icon: Iconsax.element_4, text: 'All', iconBorderRadius: TSizes.md,),
          const SizedBox(width: 12),

          TIconsText(icon: Iconsax.headphone, text: 'Audio', iconBorderRadius: TSizes.md,),
          const SizedBox(width: 12),

          TIconsText(icon: Iconsax.watch, text: 'Wearables', iconBorderRadius: TSizes.md,),
          const SizedBox(width: 12),

          TIconsText(icon: Iconsax.safe_home, text: 'Footwear', iconBorderRadius: TSizes.md,),
          const SizedBox(width: 12),

          TIconsText(icon: Iconsax.shop, text: 'Fashion', iconBorderRadius: TSizes.md,),
        ],
      ),
    );
  }
}

