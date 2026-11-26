import 'package:demo_project/features/shop/controllers/cart_controller.dart';
import 'package:demo_project/features/shop/models/cart_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// import TCurrency

/// Server money strings ("1500.00") are parsed only here, for display.
String cartMoney(String raw) => TCurrency.format(double.tryParse(raw) ?? 0);

class THorizontalCartCard extends StatelessWidget {
  const THorizontalCartCard({
    super.key,
    required this.dark,
    required this.item,
  });

  final bool dark;
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Get.find<CartController>();
    final variantLabel = [
      item.color,
      item.size,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.white,
        border: Border.all(
          color: dark ? TColors.darkGrey : TColors.borderSecondary,
        ),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            child: item.imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image(
                    image:
                        item.imageUrl.startsWith('http://') ||
                            item.imageUrl.startsWith('https://')
                        ? NetworkImage(item.imageUrl)
                        : AssetImage(item.imageUrl),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Obx(() {
                      final busy = cart.busyVariantIds.contains(item.variantId);
                      return IconButton(
                        onPressed: busy
                            ? null
                            : () => cart.removeItem(item.variantId),
                        icon: const Icon(Iconsax.trash, size: 18),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ],
                ),
                if (variantLabel.isNotEmpty)
                  Text(
                    variantLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TColors.textSecondary,
                    ),
                  ),
                Text(
                  cartMoney(item.unitPrice),
                  style: theme.textTheme.bodyMedium,
                ),
                if (!item.inStock)
                  Text(
                    'Not enough stock for this quantity',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Obx(() {
                      final busy = cart.busyVariantIds.contains(item.variantId);
                      return Row(
                        children: [
                          IconButton(
                            onPressed: busy || item.quantity <= 1
                                ? null
                                : () => cart.setQuantity(
                                    item.variantId,
                                    item.quantity - 1,
                                  ),
                            icon: const Icon(Iconsax.minus, size: 18),
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            '${item.quantity}',
                            style: theme.textTheme.titleSmall,
                          ),
                          IconButton(
                            onPressed:
                                busy ||
                                    item.quantity >= CartController.maxQuantity
                                ? null
                                : () => cart.setQuantity(
                                    item.variantId,
                                    item.quantity + 1,
                                  ),
                            icon: const Icon(Iconsax.add, size: 18),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      );
                    }),
                    const Spacer(),
                    Text(
                      cartMoney(item.lineTotal),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 80,
    height: 80,
    color: TColors.grey,
    child: const Icon(Iconsax.image),
  );
}
