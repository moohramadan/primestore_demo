import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/common/widgets/layouts/grid_layout.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.lg + 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const TShimmerEffect(width: 70, height: 70, radius: 35),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TShimmerEffect(width: 130, height: 22, radius: 6),
                      SizedBox(height: TSizes.sm),
                      TShimmerEffect(width: 90, height: 14, radius: 5),
                    ],
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                const TShimmerEffect(width: 44, height: 44, radius: 22),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            const TShimmerEffect(
              width: double.infinity,
              height: 56,
              radius: 32,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            const TShimmerEffect(
              width: double.infinity,
              height: 190,
              radius: TSizes.borderRadiusLg,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TShimmerEffect(width: 20, height: 4, radius: 2),
                  SizedBox(width: TSizes.sm),
                  TShimmerEffect(width: 20, height: 4, radius: 2),
                  SizedBox(width: TSizes.sm),
                  TShimmerEffect(width: 20, height: 4, radius: 2),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: TSizes.spaceBtwItems),
                itemBuilder: (_, _) => const SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      TShimmerEffect(width: 56, height: 56, radius: 28),
                      SizedBox(height: TSizes.sm),
                      TShimmerEffect(width: 48, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.sm),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TShimmerEffect(width: 145, height: 24, radius: 5),
                TShimmerEffect(width: 64, height: 18, radius: 5),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TGridLayout(
              itemCount: 4,
              itemBuilder: (_, _) => const _ProductCardShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TShimmerEffect(
            width: double.infinity,
            height: 150,
            radius: TSizes.borderRadiusSm,
          ),
          SizedBox(height: TSizes.sm),
          TShimmerEffect(width: double.infinity, height: 14, radius: 4),
          SizedBox(height: TSizes.sm),
          TShimmerEffect(width: 72, height: 12, radius: 4),
          SizedBox(height: TSizes.sm),
          TShimmerEffect(width: 56, height: 14, radius: 4),
        ],
      ),
    );
  }
}
