import 'package:demo_project/common/widgets/icons/icons_text.dart';
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
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.categoriesError.value != null) {
        return SizedBox(
          height: 100,
          child: Center(
            child: TextButton(
              onPressed: controller.fetchCategories,
              child: const Text('Could not load categories. Tap to retry.'),
            ),
          ),
        );
      }

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
            for (final category in controller.categories) ...[
              _categoryItem(
                context,
                name: category.name,
                icon: _iconForCategory(category.name),
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

  IconData _iconForCategory(String name) {
    switch (name.toLowerCase()) {
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
