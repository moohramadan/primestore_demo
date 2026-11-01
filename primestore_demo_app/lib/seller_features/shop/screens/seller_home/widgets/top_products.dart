import 'package:demo_project/common/widgets/list_title/top_product_tile.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TTopProducts extends StatelessWidget {
  const TTopProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       TTopProductTile(number: 1, productName: 'Nike shoes', contentPadding: EdgeInsets.all(0),),
    SizedBox(height: TSizes.xs,),
    TTopProductTile(number: 2, productName: 'Addidas Air maxes', contentPadding: EdgeInsets.all(0), numberColor: Colors.orange,),
    SizedBox(height: TSizes.xs,),
    TTopProductTile(number: 3, productName: 'Addidas Premuims', contentPadding: EdgeInsets.all(0), numberColor: Colors.red,),
      ],
    );
  }
}