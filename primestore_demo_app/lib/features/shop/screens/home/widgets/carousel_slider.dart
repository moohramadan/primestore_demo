import 'package:carousel_slider/carousel_slider.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TCarouselSlider extends StatelessWidget {
  const TCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // Local list of images
    final List<String> banners = [
      TImages.promoBanner1,
      TImages.promoBanner2,
      TImages.promoBanner3,
    ];

    // This holds the current page index
    final currentIndex = ValueNotifier<int>(0);

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1.0,
            autoPlay: true,
            onPageChanged: (index, _) {
              currentIndex.value = index;
            },
          ),
          items: banners
              .map(
                (image) => TRoundedImage(
  imageUrl: image,
  isNetworkImage: false,
  fit: BoxFit.cover,
  width: double.infinity,
  padding: EdgeInsets.zero,
  backgroundColor: Colors.transparent,
  onPressed: () {},
),
              )
              .toList(),
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // Indicators
        ValueListenableBuilder<int>(
          valueListenable: currentIndex,
          builder: (context, index, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < banners.length; i++)
                  TCircularContainer(
                    width: 20,
                    height: 4,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor:
                        index == i ? TColors.primary : TColors.grey,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}