import 'package:demo_project/common/widgets/icons/icons_text.dart';
import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/data/repositories/product_repository.dart';
import 'package:demo_project/features/shop/controllers/home_controller.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TCategoryBuilder extends StatelessWidget {
  const TCategoryBuilder({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return SizedBox(
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
        );
      }

      final categoriesFailed = controller.categoriesError.value != null;

      return SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _categoryItem(
              context,
              name: 'All',
              icon: Iconsax.element_4,
              categoryId: null,
            ),
            const SizedBox(width: 12),
            // "All" stays available even when the category list fails to load.
            if (categoriesFailed)
              Center(
                child: TextButton(
                  onPressed: controller.fetchCategories,
                  child: const Text('Could not load categories. Retry'),
                ),
              )
            else
              for (final category in controller.categories) ...[
                _categoryItem(
                  context,
                  name: category.name,
                  icon: _iconForCategory(category),
                  categoryId: category.id,
                ),
                const SizedBox(width: 12),
              ],
          ],
        ),
      );
    });
  }

  Widget _categoryItem(
    BuildContext context, {
    required String name,
    required IconData icon,
    required int? categoryId,
  }) {
    final selected = controller.selectedCategoryId.value == categoryId;
    final color = selected ? Theme.of(context).colorScheme.primary : null;
    return TIconsText(
      icon: icon,
      text: name,
      iconColor: color,
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color,
        fontWeight: selected ? FontWeight.w600 : null,
      ),
      iconBorderRadius: TSizes.md,
      onTap: () => controller.selectCategory(categoryId),
    );
  }

  /// Icons the server can ask for by slug (the `icon` column of a category).
  /// Add more entries here when you add new categories.
  static const Map<String, IconData> _iconsBySlug = {
    'all': Iconsax.element_4,
    'headphone': Iconsax.headphone,
    'watch': Iconsax.watch,
    'shop': Iconsax.shop,
    'home': Iconsax.safe_home,
    'category': Iconsax.category,
  };

  IconData _iconForCategory(ProductOption category) {
    final bySlug = _iconsBySlug[category.icon.trim().toLowerCase()];
    if (bySlug != null) return bySlug;

    // Fallback for categories whose icon slug is not set yet.
    switch (category.name.toLowerCase()) {
      case 'audio':
        return Iconsax.headphone;
      case 'wearables':
        return Iconsax.watch;
      case 'footwear':
        return Iconsax.safe_home;
      case 'fashion':
        return Iconsax.shop;
      default:
        return Iconsax.category;
    }
  }
}
