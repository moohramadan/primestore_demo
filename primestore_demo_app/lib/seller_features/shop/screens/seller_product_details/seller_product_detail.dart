import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class SellerProductDetail extends StatelessWidget {
  const SellerProductDetail({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isEmpty ? null : product.images.first;
    final imageUrl = image?.displayUrl;
    final variant = product.defaultVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
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
            for (final variant in product.variants)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  [
                        if (variant.color.isNotEmpty) variant.color,
                        if (variant.size.isNotEmpty) variant.size,
                      ].join(' · ').isEmpty
                      ? 'Standard'
                      : [
                          if (variant.color.isNotEmpty) variant.color,
                          if (variant.size.isNotEmpty) variant.size,
                        ].join(' · '),
                ),
                subtitle: Text(
                  '${variant.stock} in stock${variant.discountPercent > 0 ? ' · ${variant.discountPercent}% off' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TCurrency.format(variant.effectivePrice)),
                    if (variant.isOnSale) ...[
                      const SizedBox(width: TSizes.xs),
                      Text(
                        TCurrency.format(variant.price),
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
