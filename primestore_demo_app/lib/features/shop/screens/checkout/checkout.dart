import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: theme.textTheme.headlineSmall),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TSizes.md,
            TSizes.sm,
            TSizes.md,
            TSizes.lg,
          ),
          children: [
            Text('Delivery', style: theme.textTheme.titleLarge),
            const SizedBox(height: TSizes.sm),
            _CheckoutPanel(
              dark: dark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.location, color: TColors.primary),
                  const SizedBox(width: TSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery address',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: TSizes.xs),
                        Text(
                          'Add your delivery address',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 18,
                    color: TColors.darkGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.lg),
            Text('Payment', style: theme.textTheme.titleLarge),
            const SizedBox(height: TSizes.sm),
            _CheckoutPanel(
              dark: dark,
              child: Row(
                children: [
                  const Icon(Iconsax.card, color: TColors.primary),
                  const SizedBox(width: TSizes.md),
                  Expanded(
                    child: Text(
                      'Choose a payment method',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 18,
                    color: TColors.darkGrey,
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
                  const _SummaryLine(label: 'Cart items', value: '2 items'),
                  const SizedBox(height: TSizes.md),
                  Divider(
                    height: 1,
                    color: dark ? TColors.darkGrey : TColors.borderSecondary,
                  ),
                  const SizedBox(height: TSizes.md),
                  const _SummaryLine(label: 'Subtotal', value: '\$90.00'),
                  const SizedBox(height: TSizes.sm),
                  const _SummaryLine(
                    label: 'Delivery',
                    value: 'Calculated later',
                  ),
                  const SizedBox(height: TSizes.sm),
                  const _SummaryLine(label: 'Tax', value: 'Calculated later'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TColors.textSecondary,
                      ),
                    ),
                    Text('\$90.00', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                height: 52,
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text('Place order'),
                ),
              ),
            ],
          ),
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
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style?.copyWith(color: TColors.textSecondary),
          ),
        ),
        Text(value, style: style),
      ],
    );
  }
}
