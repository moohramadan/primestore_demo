import 'package:demo_project/common/widgets/images/round_image.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';


class TRecentText extends StatelessWidget {
  const TRecentText({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.itemCount,
    required this.price,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String date;
  final int itemCount;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: TSizes.sm,
      leading: TRoundImage(
        imageUrl: imageUrl,
        width: 64,
        height: 64,
        borderRadius: 32,
      ),
      title: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$date · $itemCount items'),
      trailing: Text(
        price,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}