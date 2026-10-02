import 'package:demo_project/seller_features/autentication/controllers/add_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One stock text field per color/size combination currently selected —
/// mirrors the "Stock per variant" list in the design (Black / M, Black / L,
/// White / M, ...). For categories with no sizing scheme, each row is just
/// the color (e.g. "Black").
class VariantStockSection extends StatelessWidget {
  const VariantStockSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = addProductController;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final keys = controller.stockControllers.keys.toList()..sort();

      if (keys.isEmpty) {
        final message = controller.needsSize
            ? 'Pick at least one color and size to set stock'
            : 'Pick at least one color to set stock';
        return Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white38 : colors.onSurfaceVariant,
            fontSize: 13,
          ),
        );
      }

      return Column(
        children: keys.map((key) {
          final parts = key.split('::');
          final color = parts[0];
          final size = parts.length > 1 ? parts[1] : null;
          final label = size == null ? color : '$color / $size';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : colors.onSurface,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 40,
                  child: TextField(
                    controller: controller.stockControllers[key],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : colors.onSurface,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: !isDark,
                      fillColor: colors.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : colors.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : colors.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2D4A7A)
                              : colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
