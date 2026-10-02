import 'package:demo_project/common/widgets/custom_shapes/containers/indicator_container.dart';
import 'package:demo_project/common/widgets/icons/round_icon.dart';
import 'package:demo_project/common/widgets/texts/product_price_text.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TProductTile extends StatelessWidget {
  const TProductTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.status = TIndicatorStatus.draft,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final TIndicatorStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: EdgeInsets.all(TSizes.sm),
      
      decoration: BoxDecoration(
        border: Border.all(  color:dark? TColors.grey: TColors.black),
        color: dark? TColors.darkerGrey: TColors.grey,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg)
      ),
      child: ListTile(
        leading: TRoundedIcon(icon: icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TProductPriceText(price: price),
            const SizedBox(height: 6),
            TIndicator(status: status),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}