import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/common/widgets/layouts/grid_layout.dart';
import 'package:demo_project/features/shop/controllers/home_controller.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/features/shop/screens/cart/cart.dart';
import 'package:demo_project/features/shop/screens/home/widgets/vertical_product_card.dart';
import 'package:demo_project/features/shop/screens/product_details/product_detail.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum _StoreSort { featured, priceLowToHigh, priceHighToLow }

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedBrand;
  _StoreSort _sort = _StoreSort.featured;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            TSizes.md,
            TSizes.lg,
            TSizes.md,
            112,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: TSizes.xs),
                        Text(
                          'Find something worth keeping.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: TColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Open cart',
                    onPressed: () => Get.to(() => CartScreen()),
                    icon: const Icon(Iconsax.shopping_bag),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TSearchBox(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
              const SizedBox(height: TSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Browse by brand',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<_StoreSort>(
                    tooltip: 'Sort products',
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _StoreSort.featured,
                        child: Text('Featured'),
                      ),
                      PopupMenuItem(
                        value: _StoreSort.priceLowToHigh,
                        child: Text('Price: low to high'),
                      ),
                      PopupMenuItem(
                        value: _StoreSort.priceHighToLow,
                        child: Text('Price: high to low'),
                      ),
                    ],
                    child: Icon(
                      Iconsax.sort,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.sm),
              Obx(() {
                final brands =
                    controller.featuredProducts
                        .map((product) => product.brandName.trim())
                        .where((brand) => brand.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();

                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _BrandChip(
                        label: 'All',
                        selected: _selectedBrand == null,
                        onSelected: () => setState(() => _selectedBrand = null),
                      ),
                      for (final brand in brands)
                        Padding(
                          padding: const EdgeInsets.only(left: TSizes.sm),
                          child: _BrandChip(
                            label: brand,
                            selected: _selectedBrand == brand,
                            onSelected: () =>
                                setState(() => _selectedBrand = brand),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: TSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Featured finds',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${_filteredProducts(controller.featuredProducts).length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() {
                if (controller.isLoading.value) {
                  return TGridLayout(
                    itemCount: 4,
                    itemBuilder: (_, index) => const TShimmerEffect(
                      width: double.infinity,
                      height: 276,
                      radius: 8,
                    ),
                  );
                }

                final products = _filteredProducts(controller.featuredProducts);
                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: TSizes.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Iconsax.shop, size: 36, color: TColors.darkGrey),
                          const SizedBox(height: TSizes.sm),
                          Text(
                            _query.isEmpty && _selectedBrand == null
                                ? 'No products to show yet'
                                : 'No products found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_query.isNotEmpty || _selectedBrand != null) ...[
                            const SizedBox(height: TSizes.xs),
                            TextButton(
                              onPressed: () => setState(() {
                                _query = '';
                                _selectedBrand = null;
                                _searchController.clear();
                              }),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return TGridLayout(
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => ProductDetail(product: product)),
                      child: TVerticalProductCard(product: product),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  List<ProductModel> _filteredProducts(Iterable<ProductModel> products) {
    final matches = products.where((product) {
      final name = product.name.toLowerCase();
      final brand = product.brandName.toLowerCase();
      return (_selectedBrand == null || product.brandName == _selectedBrand) &&
          (_query.isEmpty || name.contains(_query) || brand.contains(_query));
    }).toList();

    if (_sort == _StoreSort.priceLowToHigh ||
        _sort == _StoreSort.priceHighToLow) {
      matches.sort((first, second) {
        final firstPrice = first.defaultVariant?.effectivePrice ?? 0;
        final secondPrice = second.defaultVariant?.effectivePrice ?? 0;
        return _sort == _StoreSort.priceLowToHigh
            ? firstPrice.compareTo(secondPrice)
            : secondPrice.compareTo(firstPrice);
      });
    }
    return matches;
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: TColors.primary.withValues(alpha: 0.14),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? TColors.primary : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected
            ? TColors.primary.withValues(alpha: 0.35)
            : TColors.borderSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}
