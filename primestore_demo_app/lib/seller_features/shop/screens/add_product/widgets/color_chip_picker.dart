import 'package:demo_project/seller_features/shop/controllers/add_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ---------------------------------------------------------------------
// 1. Color name -> Color lookup
// ---------------------------------------------------------------------

final Map<String, Color> productColorMap = {
  'black': Colors.black,
  'white': Colors.white,
  'red': Colors.red,
  'blue': Colors.blue,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'gold': const Color(0xFFD4AF37),
  'silver': const Color(0xFFC0C0C0),
  'gray': Colors.grey,
  'grey': Colors.grey,
  'navy': const Color(0xFF000080),
  'brown': Colors.brown,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'orange': Colors.orange,
  'beige': const Color(0xFFF5F5DC),
  'maroon': const Color(0xFF800000),
  'teal': Colors.teal,
  'cyan': Colors.cyan,
  'olive': const Color(0xFF808000),
  'ivory': const Color(0xFFFFFFF0),
  'khaki': const Color(0xFFC3B091),
  'burgundy': const Color(0xFF800020),
  'turquoise': const Color(0xFF40E0D0),
  'lavender': const Color(0xFFE6E6FA),
  'mint': const Color(0xFF98FF98),
  'coral': const Color(0xFFFF7F50),
  'charcoal': const Color(0xFF36454F),
  'cream': const Color(0xFFFFFDD0),
  'rose gold': const Color(0xFFB76E79),
};

const Color fallbackSwatchColor = Colors.grey;

Color getColorFromName(String name) {
  return productColorMap[name.toLowerCase()] ?? fallbackSwatchColor;
}

// ---------------------------------------------------------------------
// 2. Chip widgets
// ---------------------------------------------------------------------

class ColorChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  const ColorChip({
    super.key,
    required this.name,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = getColorFromName(name);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: selected
                    ? (isDark
                          ? const Color(0xFF6EA8FE)
                          : colors.onPrimaryContainer)
                    : (isDark ? Colors.white70 : colors.onSurfaceVariant),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddColorChip extends StatelessWidget {
  final VoidCallback onTap;

  const AddColorChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white24 : colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: isDark ? Colors.white70 : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Add',
              style: TextStyle(
                color: isDark ? Colors.white70 : colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 3. Bottom sheet picker
// ---------------------------------------------------------------------

Future<void> showColorPickerSheet({
  required BuildContext context,
  required List<String> alreadySelected,
  required ValueChanged<String> onPicked,
}) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF17171A) : colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'Pick a color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: productColorMap.keys.map((name) {
                    final isTaken = alreadySelected.contains(name);
                    return Opacity(
                      opacity: isTaken ? 0.4 : 1.0,
                      child: ColorChip(
                        name: name,
                        selected: isTaken,
                        onTap: isTaken
                            ? null
                            : () {
                                onPicked(name);
                                Navigator.pop(sheetContext);
                              },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------
// 4. Wired-up section — drop this widget into your Add Product screen
// ---------------------------------------------------------------------

/// Reads/writes colors through [addProductController], which keeps the
/// per-variant stock fields (see variant_stock_section.dart) in sync
/// automatically whenever a color is added or removed.
class ColorVariantSection extends StatelessWidget {
  const ColorVariantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = addProductController;

    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...controller.selectedColors.map(
            (name) => ColorChip(
              name: name,
              selected: true,
              onTap: () => controller.removeColor(name),
            ),
          ),
          AddColorChip(
            onTap: () => showColorPickerSheet(
              context: context,
              alreadySelected: controller.selectedColors,
              onPicked: (name) => controller.addColor(name),
            ),
          ),
        ],
      ),
    );
  }
}
