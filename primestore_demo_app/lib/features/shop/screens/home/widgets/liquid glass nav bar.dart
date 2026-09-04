import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller holding the reactive selected-tab state.
/// Register with `Get.put(LiquidGlassNavController())` before use.
class LiquidGlassNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void select(int index) => selectedIndex.value = index;
}

/// A reusable item definition for the nav bar.
class LiquidGlassNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const LiquidGlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Apple-style "Liquid Glass" bottom navigation bar.
/// Stateless — all reactive state lives in [LiquidGlassNavController],
/// and only the parts that need to rebuild are wrapped in [Obx].
class LiquidGlassNavBar extends StatelessWidget {
  final List<LiquidGlassNavItem> items;
  final LiquidGlassNavController controller;
  final Color accentColor;

  /// Total bar height, including its own bottom margin/shadow allowance.
  /// 80 gives comfortable room for a 22px icon + label without overflow.
  final double height;

  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.controller,
    this.accentColor = const Color(0xFF0A84FF),
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          // The frosted, refractive "liquid glass" blur.
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha:  0.14),
                        Colors.white.withValues(alpha:0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha:0.55),
                        Colors.white.withValues(alpha:0.25),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                return _NavBarButton(
                  index: index,
                  item: items[index],
                  controller: controller,
                  accentColor: accentColor,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single tab button. Wraps only the icon/label pair in [Obx] so
/// tapping a tab doesn't rebuild the whole glass container.
class _NavBarButton extends StatelessWidget {
  final int index;
  final LiquidGlassNavItem item;
  final LiquidGlassNavController controller;
  final Color accentColor;

  const _NavBarButton({
    required this.index,
    required this.item,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.select(index),
        child: Obx(() {
          final bool isSelected = controller.selectedIndex.value == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            // Tighter margin/padding than before — this is what was
            // pushing the icon+label column past the bar's height.
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isSelected
                  ? accentColor.withValues(alpha:  0.18)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? accentColor : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? accentColor : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// --- Example usage ---
///
/// void main() {
///   Get.put(LiquidGlassNavController());
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///   @override
///   Widget build(BuildContext context) {
///     final controller = Get.find<LiquidGlassNavController>();
///     return GetMaterialApp(
///       home: Scaffold(
///         extendBody: true, // lets page content show through the glass
///         body: Obx(() => Center(
///               child: Text('Page ${controller.selectedIndex.value}'),
///             )),
///         bottomNavigationBar: LiquidGlassNavBar(
///           controller: controller,
///           items: const [
///             LiquidGlassNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
///             LiquidGlassNavItem(icon: Icons.search, label: 'Search'),
///             LiquidGlassNavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Likes'),
///             LiquidGlassNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
///           ],
///         ),
///       ),
///     );
///   }
/// }
