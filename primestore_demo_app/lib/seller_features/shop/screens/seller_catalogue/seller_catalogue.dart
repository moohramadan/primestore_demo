import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/common/widgets/list_title/product_tile.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/data/repositories/product_repository.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/add_product.dart';
import 'package:demo_project/seller_features/shop/screens/seller_product_details/seller_product_detail.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SellerCatalogueScreen extends StatefulWidget {
  const SellerCatalogueScreen({super.key});

  @override
  State<SellerCatalogueScreen> createState() => _SellerCatalogueScreenState();
}

class _SellerCatalogueScreenState extends State<SellerCatalogueScreen> {
  final ProductRepository _repository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _repository.fetchSellerProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
        if (_selectedCategory != null &&
            !products.any((p) => p.categoryName == _selectedCategory)) {
          _selectedCategory = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddProduct() async {
    await Get.to(() => const AddProductScreen());
    if (mounted) await _loadProducts();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brandName.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null ||
          product.categoryName == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    final names =
        _products
            .map((product) => product.categoryName)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final products = _filteredProducts;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: TSizes.defaultSpace,
          ),
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TSectionHeading(
                  title: 'Products',
                  showActionButton: false,
                  fontsize: TSizes.md - 2,
                ),
                GestureDetector(
                  onTap: _openAddProduct,
                  child: TRoundedContainer(
                    radius: 40,
                    padding: const EdgeInsets.symmetric(
                      vertical: TSizes.sm + 2,
                      horizontal: TSizes.md,
                    ),
                    backgroundColor: dark ? TColors.darkerGrey : TColors.black,
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: TColors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Add',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.apply(color: TColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm),
            if (_isLoading)
              const TShimmerEffect(width: 112, height: 12, radius: 4)
            else
              Text(
                '${products.length} of ${_products.length} products',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.apply(fontSizeDelta: TSizes.sm - 4),
              ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TSearchBox(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            if (_isLoading)
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: TSizes.sm),
                  itemBuilder: (_, _) => const Center(
                    child: TShimmerEffect(width: 76, height: 32, radius: 20),
                  ),
                ),
              )
            else if (_categories.isNotEmpty)
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryChip('All', null),
                    for (final category in _categories)
                      _categoryChip(category, category),
                  ],
                ),
              ),
            const SizedBox(height: TSizes.spaceBtwItems + 10),
            if (_isLoading)
              const _CatalogueLoadingShimmer()
            else if (_error != null)
              _CatalogueMessage(
                icon: Iconsax.warning_2,
                message: _error!,
                actionLabel: 'Retry',
                onAction: _loadProducts,
              )
            else if (products.isEmpty)
              _CatalogueMessage(
                icon: Iconsax.box,
                message: _products.isEmpty
                    ? 'You have not added any products yet.'
                    : 'No products match your search.',
                actionLabel: _products.isEmpty ? 'Add product' : null,
                onAction: _products.isEmpty ? _openAddProduct : null,
              )
            else
              for (var i = 0; i < products.length; i++) ...[
                _productTile(products[i]),
                if (i != products.length - 1)
                  const SizedBox(height: TSizes.spaceBtwInputFields),
              ],
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, String? category) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: TSizes.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _productTile(ProductModel product) {
    final price = product.defaultVariant?.effectivePrice;
    return TProductTile(
      title: product.name,
      subtitle: product.categoryName.isEmpty
          ? product.brandName
          : product.categoryName,
      price: price,
      originalPrice: product.defaultVariant?.price,
      icon: Iconsax.box,
      imageUrl: product.mainImageUrl,
      onTap: () => Get.to(
        () => SellerProductDetail(
          product: product,
          onProductChanged: _replaceProduct,
        ),
      ),
    );
  }

  /// Swaps one edited product into the list without reloading everything,
  /// so the scroll position, search text and category filter stay as they were.
  void _replaceProduct(ProductModel updated) {
    if (!mounted) return;
    setState(() {
      _products = [
        for (final item in _products) item.id == updated.id ? updated : item,
      ];
    });
  }
}

class _CatalogueLoadingShimmer extends StatelessWidget {
  const _CatalogueLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 4; index++) ...[
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
            ),
            child: const Row(
              children: [
                TShimmerEffect(width: 48, height: 48, radius: 8),
                SizedBox(width: TSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TShimmerEffect(
                        width: double.infinity,
                        height: 14,
                        radius: 4,
                      ),
                      SizedBox(height: TSizes.sm),
                      TShimmerEffect(width: 88, height: 12, radius: 4),
                    ],
                  ),
                ),
                SizedBox(width: TSizes.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TShimmerEffect(width: 64, height: 14, radius: 4),
                    SizedBox(height: TSizes.sm),
                    TShimmerEffect(width: 44, height: 12, radius: 4),
                  ],
                ),
              ],
            ),
          ),
          if (index != 3)
            const SizedBox(height: TSizes.spaceBtwInputFields),
        ],
      ],
    );
  }
}

class _CatalogueMessage extends StatelessWidget {
  const _CatalogueMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xl),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
