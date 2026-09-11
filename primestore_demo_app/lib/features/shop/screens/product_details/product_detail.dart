
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/shop/controllers/product_detail_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/features/shop/screens/product_details/widgets/bottom_add_cart_widget.dart';
import 'package:demo_project/features/shop/screens/product_details/widgets/product_attributes.dart';
import 'package:demo_project/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:demo_project/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:demo_project/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';


class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
  ProductDetailController(product: product),
  tag: product.id.toString(),
);

    return Scaffold(
      bottomNavigationBar: TBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Product Image Slider
            TProductImageSlider(images: product.images, product: product, ),

            /// Product Details
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Rating & Share button
                  const TRatingAndShare(), // static for now, per earlier decision

                  /// Price, Title, Stock, Brand
                  TProductMetaData(product: product),

                  /// Attributes
                  TProductAttributes(product: product),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Checkout'),
                    ),
                  ),

                  /// Description
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(
                    title: 'Description',
                    showActionButton: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ReadMoreText(
                    product.description,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Less',
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  // - Reviews (static for now, per earlier decision)
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TSectionHeading(
                        title: 'Reviews (199)',
                        showActionButton: false,
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_3, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
