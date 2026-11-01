import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class THorizontalCartCard extends StatelessWidget {
  const THorizontalCartCard({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
            child: Image.asset(TImages.productImage1, fit: BoxFit.contain),
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nike Shoes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  "FootWear",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: TSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$45.00',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkGrey : TColors.grey,
                        borderRadius: BorderRadius.circular(
                          TSizes.borderRadiusXl,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            onPressed: () {},
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(TSizes.xs),
                          ),
                          Text(
                            '1',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 14,
                              color: TColors.white,
                            ),
                            onPressed: () {},
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
