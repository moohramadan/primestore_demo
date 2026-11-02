import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/primary_header_container.dart';
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
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the registered controller instead of building a new one on every rebuild.
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TPrimaryHeaderContainer(
              height: 550,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: TSizes.xl,
                  right: TSizes.sm,
                  left: TSizes.sm
                ),
                child: Column(
                  children: [
                TWelcomecart(),
                SizedBox(height: TSizes.spaceBtwItems),
                TSearchBox(),
                SizedBox(height: TSizes.spaceBtwItems),
                TCarouselSlider(),
                SizedBox(height: TSizes.spaceBtwItems),
                TCategoryBuilder(controller: controller),
                SizedBox(height: TSizes.sm),
                  ],
                ),
              ),
            ),
            
        
            Obx(() {
              final products = controller.featuredProducts;
              if (controller.isLoading.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TSectionHeading(
                      title: controller.selectedCategoryName,
                      textButtonColor: TColors.primary,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TGridLayout(
                      itemCount: 4,
                      itemBuilder: (_, index) => const TShimmerEffect(
                        width: double.infinity,
                        height: 260,
                        radius: 8,
                      ),
                    ),
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TSectionHeading(
                      title: controller.selectedCategoryName,
                      textButtonColor: TColors.primary,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    if (controller.productsError.value != null)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              controller.productsError.value!,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: controller.retrySelectedCategory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (products.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: TSizes.md,
                             vertical: TSizes.lg + 10,
                            ),
                          child: Text('No products found in this category.'),
                        ),
                      )
                    else
                      TGridLayout(
                        itemCount: products.length,
                        itemBuilder: (_, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () =>
                                Get.to(() => ProductDetail(product: product)),
                            child: TVerticalProductCard(product: product),
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TWelcomecart extends StatelessWidget {
  const TWelcomecart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
    );
  }
}
