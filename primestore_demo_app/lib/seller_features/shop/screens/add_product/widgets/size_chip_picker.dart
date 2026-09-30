import 'package:demo_project/seller_features/shop/controllers/add_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A plain toggle chip, styled to match [ColorChip] in color_chip_picker.dart
/// but without a color dot — used for both clothing and shoe sizes.
class SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SizeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? const Color(0xFF16233D) : colors.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? (isDark ? const Color(0xFF2D4A7A) : colors.primary)
                : (isDark ? Colors.white24 : colors.outlineVariant),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDark ? const Color(0xFF6EA8FE) : colors.onPrimaryContainer)
                : (isDark ? Colors.white70 : colors.onSurfaceVariant),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Shows the size chips for whichever sizing scheme the currently selected
/// category uses (clothing sizes, shoe sizes, or none). Renders nothing when
/// the category has no sizing scheme (e.g. Electronics, Audio) — variants
/// for those are color-only.
class SizeVariantSection extends StatelessWidget {
  const SizeVariantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = addProductController;

    return Obx(() {
      final sizes = controller.availableSizes;
      if (sizes.isEmpty) return const SizedBox.shrink();

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: sizes.map((size) {
          final selected = controller.selectedSizes.contains(size);
          return SizeChip(
            label: size,
            selected: selected,
            onTap: () => controller.toggleSize(size),
          );
        }).toList(),
      );
    });
  }
}
