import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/seller_features/shop/screens/seller_product_details/edit_seller_product.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProductDetail extends StatefulWidget {
  const SellerProductDetail({
    super.key,
    required this.product,
    this.onProductChanged,
  });

  final ProductModel product;

  /// Called after a successful edit so the list behind this screen can update.
  final ValueChanged<ProductModel>? onProductChanged;

  @override
  State<SellerProductDetail> createState() => _SellerProductDetailState();
}

class _SellerProductDetailState extends State<SellerProductDetail> {
  late ProductModel _product = widget.product;

  Future<void> _editProduct() async {
    final updatedProduct = await Get.to<ProductModel>(
      () => EditSellerProductScreen(product: _product),
    );
    if (updatedProduct != null && mounted) {
      setState(() => _product = updatedProduct);
      widget.onProductChanged?.call(updatedProduct);
      TLoaders.successSnackBar(
        title: 'Product updated',
        message: 'Your changes were saved successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final image = product.images.isEmpty ? null : product.images.first;
    final imageUrl = image?.displayUrl;
    final variant = product.defaultVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            onPressed: _editProduct,
            tooltip: 'Edit product',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              child: Image(
                height: 260,
                fit: BoxFit.cover,
                image: image!.isNetworkImage
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl) as ImageProvider,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 260,
                  child: Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            )
          else
            const SizedBox(
              height: 260,
              child: Icon(Icons.image_not_supported_outlined, size: 48),
            ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          if (variant != null) ...[
            const SizedBox(height: TSizes.sm),
            Row(
              children: [
                Text(
                  TCurrency.format(variant.effectivePrice),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (variant.isOnSale) ...[
                  const SizedBox(width: TSizes.sm),
                  Text(
                    TCurrency.format(variant.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: TSizes.spaceBtwItems),
          _DetailRow(label: 'Category', value: product.categoryName),
          _DetailRow(label: 'Brand', value: product.brandName),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TSizes.xs),
          Text(
            product.description.isEmpty
                ? 'No description provided.'
                : product.description,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text('Variants', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TSizes.xs),
          if (product.variants.isEmpty)
            const Text('No variants')
          else
            for (final item in product.variants)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.label),
                subtitle: Text(
                  '${item.stock} in stock${item.discountPercent > 0 ? ' · ${item.discountPercent}% off' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TCurrency.format(item.effectivePrice)),
                    if (item.isOnSale) ...[
                      const SizedBox(width: TSizes.xs),
                      Text(
                        TCurrency.format(item.price),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}
