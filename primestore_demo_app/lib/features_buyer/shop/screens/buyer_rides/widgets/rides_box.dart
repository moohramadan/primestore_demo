import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';


class TRidesBox extends StatelessWidget {
  const TRidesBox({
    super.key,
    required this.icon,
    required this.text,
    required this.dateTitle,
    required this.priceTitle,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final String dateTitle;
  final String priceTitle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                // Leading Icon
                Container(
                  padding: EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: TColors.grey,
                  ),
                  child: Icon(
                    icon,
                    color: TColors.primary,
                  ),
                ),
                const SizedBox(width: TSizes.md),

                // Text and Subtext
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                dateTitle,
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                priceTitle,
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow Icon
                Container(
                  padding: EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: TColors.grey,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            Divider(thickness: 0.5),
          ],
        ),
      ),
    );
  }
}