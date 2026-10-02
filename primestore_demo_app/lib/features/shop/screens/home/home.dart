import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/layouts/grid_layout.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/shop/controllers/home_controller.dart';
import 'package:demo_project/features/shop/screens/cart/cart.dart';
import 'package:demo_project/features/shop/screens/home/widgets/carousel_slider.dart';
import 'package:demo_project/features/shop/screens/home/widgets/category_item.dart';
import 'package:demo_project/features/shop/screens/home/widgets/vertical_product_card.dart';
import 'package:demo_project/features/shop/screens/product_details/product_detail.dart';
import 'package:demo_project/utils/constants/colors.dart';

import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: TSizes.md,
            vertical: TSizes.lg + 10,
          ),
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
                  SizedBox(width: 7),
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
                  SizedBox(width: 60),
                  TGlassMorphism(
                    child: GestureDetector(
                      onTap: () => Get.to(() => CartScreen()),
                      child: Icon(Iconsax.shopping_bag),
                    ),
                  ),
                ],
              ),

              SizedBox(height: TSizes.spaceBtwItems),
              TSearchBox(),
              SizedBox(height: TSizes.spaceBtwItems),
              TCarouselSlider(),
              SizedBox(height: TSizes.spaceBtwItems),
              TCategoryBuilder(),
              SizedBox(height: TSizes.sm),

              TSectionHeading(
                title: 'Featured Products',
                textButtonColor: TColors.primary,
              ),
              SizedBox(height: TSizes.spaceBtwItems),

              Obx(() {
                if (controller.isLoading.value) {
                  return TGridLayout(
                    itemCount: 4,
                    itemBuilder: (_, index) => const TShimmerEffect(
                      width: double.infinity,
                      height: 260,
                      radius: 8,
                    ),
                  );
                }
                return TGridLayout(
                  itemCount: controller.featuredProducts.length,
                  itemBuilder: (_, index) {
                    final product = controller.featuredProducts[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => ProductDetail(product: product)),
                      child: TVerticalProductCard(product: product),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
