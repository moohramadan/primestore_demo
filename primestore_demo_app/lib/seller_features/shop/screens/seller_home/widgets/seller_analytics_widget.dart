import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TSellerAnalyticsWidget extends StatelessWidget {
  const TSellerAnalyticsWidget({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _barHeights = [34.0, 52.0, 43.0, 68.0, 48.0, 76.0, 58.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final mutedColor = dark ? TColors.darkGrey : TColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.white,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        border: Border.all(
          color: dark ? TColors.darkGrey : TColors.borderSecondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Analytics', style: theme.textTheme.titleMedium),
              ),
              Text(
                'SAMPLE DATA',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Orders',
                  value: '148',
                  change: '+12.8%',
                  mutedColor: mutedColor,
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: dark ? TColors.darkGrey : TColors.borderSecondary,
              ),
              Expanded(
                child: _Metric(
                  label: 'Conversion',
                  value: '3.6%',
                  change: '+0.4%',
                  mutedColor: mutedColor,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          SizedBox(
            height: 86,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_days.length, (index) {
                final isLatest = index == _days.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: _barHeights[index],
                              decoration: BoxDecoration(
                                color: isLatest
                                    ? TColors.primary
                                    : TColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.xs),
                        Text(
                          _days[index],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.change,
    required this.mutedColor,
    required this.theme,
  });

  final String label;
  final String value;
  final String change;
  final Color mutedColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
          const SizedBox(height: TSizes.xs),
          Row(
            children: [
              Text(value, style: theme.textTheme.titleLarge),
              const SizedBox(width: TSizes.xs),
              Flexible(
                child: Text(
                  change,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: TColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
