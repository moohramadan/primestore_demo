import 'package:demo_project/common/widgets/icons/round_icon.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/currency.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TProductTile extends StatelessWidget {
  const TProductTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    required this.icon,
    this.onTap,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final double? price;
  final double? originalPrice;
  final IconData icon;
  final VoidCallback? onTap;
  final String? imageUrl;

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
        leading: imageUrl == null
            ? TRoundedIcon(icon: icon)
            : ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                child: Image(
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  image: imageUrl!.startsWith('http')
                      ? NetworkImage(imageUrl!)
                      : AssetImage(imageUrl!) as ImageProvider,
                  errorBuilder: (_, _, _) => TRoundedIcon(icon: icon),
                ),
              ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (price == null)
              const Text('—')
            else ...[
              Text(
                TCurrency.format(price!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (originalPrice != null && originalPrice! > price!) ...[
                const SizedBox(height: 2),
                Text(
                  TCurrency.format(originalPrice!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                ),
              ],
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}