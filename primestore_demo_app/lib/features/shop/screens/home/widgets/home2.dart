import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/glass_morphism/search_container.dart';
import 'package:demo_project/common/widgets/layouts/grid_layout.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/shop/screens/cart/cart.dart';
import 'package:demo_project/features/shop/screens/home/widgets/carousel_slider.dart';
import 'package:demo_project/features/shop/screens/home/widgets/category_item.dart';
import 'package:demo_project/features/shop/screens/home/widgets/glass_vertical_card.dart';
import 'package:demo_project/features/shop/screens/home/widgets/scaffold_style.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class Home2 extends StatelessWidget {
  const Home2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBodyBehindAppBar: true,        // if you have a transparent AppBar
  backgroundColor: Colors.transparent, // let the gradient show through
  
  body: TAppBackgroundDark(
    child: SafeArea(
      child: SingleChildScrollView(
        
        child: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: TSizes.md, vertical: TSizes.lg + 10,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundColor: TColors.primary.withValues(alpha: 0.1),
                  child: Icon(Iconsax.user),
                ),
              ),
              SizedBox(width: 7,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      'Welcome',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      '@mooh',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 60,),
              TGlassMorphism(child: GestureDetector(onTap: () => Get.to(() => CartScreen()), child: Icon(Iconsax.shopping_bag,)))
            ],
          ),

           SizedBox(height: TSizes.spaceBtwItems,),
           TGlassSearchContainer(),
           SizedBox(height: TSizes.spaceBtwItems,),
           TCarouselSlider(),
          SizedBox(height: TSizes.spaceBtwItems,),
          TCategoryBuilder(),
          SizedBox(height: TSizes.spaceBtwItems,),

         TSectionHeading( title: 'Featured Products', textButtonColor: TColors.primary,),
         SizedBox(height: TSizes.spaceBtwItems,),
         
         TGridLayout(itemCount: 8, itemBuilder: (BuildContext p1, int p2) { return const TGlassVerticalCard(); },),
         SizedBox(height: TSizes.spaceBtwItems,),
         
        
        
          ],
        ),
        ),
      ), // ListView, Column, etc.
    ),
  ),
)
;
  }
}
