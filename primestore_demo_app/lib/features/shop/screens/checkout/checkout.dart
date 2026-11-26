import 'package:demo_project/common/widgets/cards/vertical_cart_card.dart';
import 'package:demo_project/features/personalization/models/address_model.dart';
import 'package:demo_project/features/shop/controllers/cart_controller.dart';
import 'package:demo_project/features/shop/controllers/checkout_controller.dart';
import 'package:demo_project/features/shop/models/order_model.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    final cartController = Get.find<CartController>();
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: theme.textTheme.headlineSmall),
      ),
      body: Obx(() {
        final placedOrder = controller.order.value;
        if (placedOrder != null) {
          return _OrderPlacedView(order: placedOrder);
        }

        final cart = cartController.cart.value;
        if (cart == null) {
          return Center(
            child: cartController.isLoading.value
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Couldn't load your cart"),
                      const SizedBox(height: TSizes.sm),
                      ElevatedButton(
                        onPressed: cartController.fetchCart,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
          );
        }

        if (cart.items.isEmpty) {
          return const Center(child: Text('Your cart is empty'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            TSizes.md,
            TSizes.sm,
            TSizes.md,
            TSizes.lg,
          ),
          children: [
            Text('Delivery address', style: theme.textTheme.titleLarge),
            const SizedBox(height: TSizes.sm),
            _addressPicker(context, controller, dark),
            const SizedBox(height: TSizes.lg),
            Text('Payment', style: theme.textTheme.titleLarge),
            const SizedBox(height: TSizes.sm),
            _CheckoutPanel(
              dark: dark,
              child: const Row(
                children: [
                  Icon(Iconsax.card, color: TColors.primary),
                  SizedBox(width: TSizes.md),
                  Expanded(
                    child: Text(
                      'Payment is not collected online. This order will be '
                      'created with unpaid status.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.lg),
            Text('Order summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: TSizes.sm),
            _CheckoutPanel(
              dark: dark,
              child: Column(
                children: [
                  for (final item in cart.items) ...[
                    _SummaryLine(
                      label: '${item.name} × ${item.quantity}',
                      value: cartMoney(item.lineTotal),
                    ),
                    const SizedBox(height: TSizes.sm),
                  ],
                  Divider(
                    height: 1,
                    color: dark ? TColors.darkGrey : TColors.borderSecondary,
                  ),
                  const SizedBox(height: TSizes.md),
                  _SummaryLine(
                    label: 'Subtotal',
                    value: cartMoney(cart.subtotal),
                  ),
                  const SizedBox(height: TSizes.sm),
                  const _SummaryLine(label: 'Delivery', value: 'Free'),
                  const SizedBox(height: TSizes.sm),
                  _SummaryLine(
                    label: 'Total',
                    value: cartMoney(cart.subtotal),
                    emphasized: true,
                  ),
                ],
              ),
            ),
            if (cartController.hasUnavailableItems) ...[
              const SizedBox(height: TSizes.md),
              const _WarningMessage(
                message:
                    'Some cart items are out of stock. Update your cart '
                    'before placing the order.',
              ),
            ],
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final placedOrder = controller.order.value;
        if (placedOrder != null) {
          return _BottomAction(
            dark: dark,
            label: 'Back to cart',
            onPressed: Get.back,
          );
        }

        final cart = cartController.cart.value;
        final canPlaceOrder =
            cart != null &&
            cart.items.isNotEmpty &&
            controller.selectedAddressId.value != null &&
            !cartController.hasUnavailableItems &&
            !controller.isPlacingOrder.value;

        return _BottomAction(
          dark: dark,
          label: controller.isPlacingOrder.value
              ? 'Placing order...'
              : 'Place order',
          onPressed: canPlaceOrder ? controller.placeOrder : null,
          isLoading: controller.isPlacingOrder.value,
        );
      }),
    );
  }

  Widget _addressPicker(
    BuildContext context,
    CheckoutController controller,
    bool dark,
  ) {
    final theme = Theme.of(context);
    return _CheckoutPanel(
      dark: dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.isLoadingAddresses.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(TSizes.md),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.addressError.value != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.addressError.value!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TColors.error,
                  ),
                ),
                TextButton(
                  onPressed: controller.fetchAddresses,
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (controller.addresses.isEmpty)
            Text(
              'No saved addresses yet. Add one to continue.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final address in controller.addresses)
              _AddressOption(
                address: address,
                selected: controller.selectedAddressId.value == address.id,
                onTap: () => controller.selectAddress(address.id),
              ),
          const SizedBox(height: TSizes.sm),
          OutlinedButton.icon(
            onPressed: controller.isLoadingAddresses.value
                ? null
                : controller.addAddress,
            icon: const Icon(Iconsax.add),
            label: Text(
              controller.addresses.isEmpty
                  ? 'Add delivery address'
                  : 'Add another address',
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressLines = [
      address.addressLine1,
      address.addressLine2,
      address.city,
      address.state,
      address.postalCode,
      address.country,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? TColors.primary : TColors.darkGrey,
            ),
            const SizedBox(width: TSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.fullName, style: theme.textTheme.titleSmall),
                  const SizedBox(height: TSizes.xs),
                  Text(addressLines, style: theme.textTheme.bodySmall),
                  Text(address.phone, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (address.isDefault)
              Text(
                'Default',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: TColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderPlacedView extends StatelessWidget {
  const _OrderPlacedView({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.tick_circle, color: TColors.success, size: 72),
            const SizedBox(height: TSizes.md),
            Text('Order placed', style: theme.textTheme.headlineSmall),
            const SizedBox(height: TSizes.sm),
            Text(
              'Order ${order.orderNumber}',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              'Total ${cartMoney(order.total)} · ${order.paymentStatus}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.dark, required this.child});

  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.white,
        border: Border.all(
          color: dark ? TColors.darkGrey : TColors.borderSecondary,
        ),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      child: child,
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized ? Theme.of(context).textTheme.titleSmall : style,
          ),
        ),
        Text(
          value,
          style: emphasized ? Theme.of(context).textTheme.titleSmall : style,
        ),
      ],
    );
  }
}

class _WarningMessage extends StatelessWidget {
  const _WarningMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: TColors.error),
  );
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.dark,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool dark;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          TSizes.md,
          TSizes.md,
          TSizes.md,
          TSizes.sm,
        ),
        decoration: BoxDecoration(
          color: dark ? TColors.darkerGrey : TColors.white,
          border: Border(
            top: BorderSide(
              color: dark ? TColors.darkGrey : TColors.borderSecondary,
            ),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}
