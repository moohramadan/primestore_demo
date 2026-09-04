import 'package:demo_project/common/widgets/icons/t_circular_icon.dart';
import 'package:demo_project/features_buyer/shop/screens/buyer_route/buyer_route.dart';
import 'package:demo_project/features_buyer/shop/screens/buyer_route/widgets/location_box.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: TSizes.spaceBtwInputFields),
            const Center(
              child: Text(
                'prime transport',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            GestureDetector(
              onTap: () => Get.to(() => BuyerRoute()),
              child: Container(
                height: 60,
                padding: EdgeInsets.all(TSizes.sm + 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: dark ? TColors.darkGrey : TColors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.search_normal, size: 25),
                    SizedBox(width: 10),
                    Text(
                      'Where do we deliver?',
                      style: Theme.of(context).textTheme.titleSmall!.apply(
                        color: dark ? TColors.grey : TColors.darkerGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Container(
              padding: EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                border: BoxBorder.all(
                  color: dark ? TColors.darkGrey : TColors.grey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TLocationBox(
                    icon: Iconsax.clock,
                    text: 'Wuse Market',
                    subText: '14 Kashim Ibrahim Street, Abuja',
                    showDivider: true,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  TLocationBox(
                    icon: Iconsax.clock,
                    text: 'Transcorp Hilton Abuja',
                    subText: '1 Aguiyi Ironsi Street, Abuja',
                    showDivider: true,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  TLocationBox(
                    icon: Iconsax.clock,
                    text: 'Jabi Motor Park',
                    subText: '92 Bimbo Akintola Way, Abuja',
                  )
                ],
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('For you', style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: 5),),
                TCircularIcon(icon: Iconsax.arrow_right_1, color: TColors.black, backgroundColor: dark? TColors.darkerGrey : TColors.grey, ),
                
              ],
              
            ),
            SizedBox(height: 6,),
            Row(
              children: [
                Column(
                  children: [
                    TCircularIcon(
                      padding: TSizes.md,
                      size: 50,
                      icon: Iconsax.car,
                      backgroundColor: dark? TColors.darkerGrey: TColors.grey,
                      ),
                      SizedBox(height: TSizes.sm, ),
                      Text('Ride', style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.primary),)
                  ],
                ),
                SizedBox(width: TSizes.md,),
                Column(
                  children: [
                    TCircularIcon(
                      padding: TSizes.md,
                      size: 50,
                      icon: Icons.motorcycle,
                      backgroundColor: dark? TColors.darkerGrey: TColors.grey,
                      ),
                      SizedBox(height: TSizes.sm, ),
                      Text('Courier', style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.primary),)
                  ],
                ),
                SizedBox(width: TSizes.md,),
                Column(
                  children: [
                    TCircularIcon(
                      padding: TSizes.md,
                      size: 50,
                      icon: Icons.calendar_month,
                      backgroundColor: dark? TColors.darkerGrey: TColors.grey,
                      ),
                      SizedBox(height: TSizes.sm, ),
                      Text('Schedule', style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.primary),)
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
