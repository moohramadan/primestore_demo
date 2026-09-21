
import 'package:demo_project/common/widgets/appbar/appbar.dart';
import 'package:demo_project/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:demo_project/common/widgets/icons/wislist_icon.dart';
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:iconsax/iconsax.dart';

class ProductImageController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void selectImage(int index) => selectedIndex.value = index;
}

class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({super.key, required this.images, required this.product});

  final List<ProductImageModel> images;
   final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(ProductImageController());
    
    return TCurvedEdgesWidget(
      child: Container(
        color: dark ? TColors.darkGrey : TColors.light,
        child: Stack(
          children: [
            /// Main large image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.productImageRadius * 2),
                child: Center(
                  child: Obx(() {
                    if (images.isEmpty) {
                      return const Icon(Iconsax.gallery_slash, size: 64);
                    }
                    final url = images[controller.selectedIndex.value].imageUrl;
                    return url.startsWith('http')
                        ? Image.network(url)
                        : Image.asset(url);
                  }),
                ),
              ),
            ),

            /// Image thumbnails
            Positioned(
              right: 0,
              bottom: 30,
              left: TSizes.defaultSpace,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  itemCount: images.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(width: TSizes.spaceBtwItems),
                  itemBuilder: (_, index) => GestureDetector(
  onTap: () => controller.selectImage(index),
  child: TRoundedImage(
    width: 80,
    backgroundColor: dark ? TColors.dark : TColors.white,
    border: Border.all(color: TColors.darkerGrey),
    padding: const EdgeInsets.all(TSizes.sm),
    imageUrl: images[index].imageUrl,
    isNetworkImage: images[index].imageUrl.startsWith('http'),
  ),
),

                ),
              ),
            ),
            TAppBar(
              showBackArrow: true,
              actions: [
                WishlistIconButton(product: product, size: 26,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
