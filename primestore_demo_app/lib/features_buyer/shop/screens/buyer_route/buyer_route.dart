import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/glass_morphism/search_container.dart';
import 'package:demo_project/features_buyer/shop/screens/buyer_route/widgets/dummy_locations.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class BuyerRoute extends StatelessWidget {
  const BuyerRoute({super.key});

@override
Widget build(BuildContext context) {
  final dark = THelperFunctions.isDarkMode(context);
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    body: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight),
              color: dark ? TColors.black : TColors.light,
            ), // Container
            // Positioned
            // ...rest of your Positioned blobs...
            SafeArea(
              child: Column(
                
                children: [
                  AppBar(
                   leading: Padding(
                     padding: const EdgeInsets.all(3),
                     child: GestureDetector(onTap: () => Get.back(), child: TGlassMorphism( child: Icon(Iconsax.close_circle, color: TColors.white,))),
                   ),
                   title: Text('Route', style: Theme.of(context).textTheme.headlineMedium,),
                   titleSpacing: 100,
                  ),
                  SizedBox(height:  TSizes.md),
                  
                  Padding(
                    padding: const EdgeInsets.only(right:  70),

                    child: Column(
                      children: [
                        TGlassMorphism(
                          borderRadius: 12,
                          child: Row(
                          children: [
                            Icon(Iconsax.location),
                            SizedBox(width: 8,),
                            Text('Current Location', style: Theme.of(context).textTheme.titleSmall,),
                          ],
                        )),
                        SizedBox(height: TSizes.sm,),
                        TGlassSearchContainer(),
                        SizedBox(height: TSizes.spaceBtwItems,),
                      ],
                    ),
                  ),
                  
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TDummyLocations(),
                 )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

