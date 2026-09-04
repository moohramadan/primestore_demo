import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';


class TLocationBox extends StatelessWidget {
  const TLocationBox( {
    super.key,
    required this.icon,
    required this.text,
    required this.subText,
    this.showSubText = true,
    this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String text;
  final String subText;
  final bool showSubText;
  final VoidCallback? onTap;
  final bool showDivider;

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
                  padding: EdgeInsets.all(TSizes.sm),
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
                                 maxLines: 1,
                               ),
                               
                               if (showSubText)
                                 Text(
                                   subText,
                                   style: Theme.of(context).textTheme.labelLarge!.apply(fontSizeDelta: 1),
                                   overflow: TextOverflow.ellipsis,
                                   maxLines: 1,
                                 ),
                              if (showSubText && showDivider)
                              Divider(thickness: 0.5,),
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
            
          ],
        ),
      ),
    );
  }
}