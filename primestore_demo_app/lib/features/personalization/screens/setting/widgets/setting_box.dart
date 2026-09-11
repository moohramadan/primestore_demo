import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TSettingBox extends StatelessWidget {
  const TSettingBox({
    super.key,
    required this.icon,
    required this.text,
    required this.subText,
    this.showSubText = true,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final String subText;
  final bool showSubText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
             
            ),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  child: Icon(
                    icon,
                    size: 25,
                    color: TColors.brand,
                  ),
                ),
                const SizedBox(width: TSizes.md + 5),
                
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
                                 style: Theme.of(context).textTheme.titleMedium!.apply(fontSizeDelta: 2),
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 1,
                               ),
                               if (showSubText)
                                 Text(
                                   subText,
                                   style: Theme.of(context).textTheme.bodySmall,
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
                
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
        ],
      ),
    );
  }
}