import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';

import 'package:flutter/material.dart';

class TCouponCode extends StatelessWidget {
  const TCouponCode({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      backgroundColor: dark? TColors.dark : TColors.white,
      showBorder: true,
      padding: EdgeInsets.only(top: TSizes.sm, bottom: TSizes.sm, right: TSizes.sm, left: TSizes.md ),
      child: Row(
        children: [
          ///Text fied
          Flexible(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Have a promo code? enter here',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          /// button
          SizedBox(
            width: 80,  
            child:  ElevatedButton(
              onPressed: (){}, 
              style: ElevatedButton.styleFrom(
                foregroundColor: dark
                 ? TColors.white.withValues(alpha: 0.5)
                 : TColors.dark.withValues(alpha: 0.5),
                 backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  side: BorderSide(
                 color: Colors.grey.withValues(alpha: 0.1),
               ),
              ),
              child: Text('Apply')
            )
            )
        ],
      ),
    );
  }
}