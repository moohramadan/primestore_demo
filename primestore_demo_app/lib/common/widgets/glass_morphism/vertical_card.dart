import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TVerticalGlassCard extends StatelessWidget {
  const TVerticalGlassCard({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return TGlassMorphism(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
               color: TColors.white,
               borderRadius: BorderRadius.circular(10)
              ),
              height: 100,
              padding: EdgeInsets.all(8),
              child: Image(image: AssetImage(TImages.productImage1,), height: 80, width: 80,),
            ),
          ),
          SizedBox(width: TSizes.sm,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  'Nike Shoes',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  "Men's wear",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Row(
      
      children: [
        Text(
          '\$45.00',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 80,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color:  dark?  TColors.darkGrey: TColors.grey ,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
    icon: const Icon(Icons.remove, size: 14),
    onPressed: () {
      // decrease quantity
    },
    constraints: const BoxConstraints(),
    padding: const EdgeInsets.all(6),
              ),
              const SizedBox(width: 4),
               Text(
    '1',
    style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: 10),
              Container(
    height: 40,
    width: 40,
    decoration: const BoxDecoration(
      color: TColors.primary,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: const Icon(Icons.add, size: 14, color: Colors.white),
      onPressed: () {
        // increase quantity
      },
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(6),
    ),
              ),
            ],
          ),
        ),
      ],
    )
    
            ],
          )
        ],
      ),
      
      );
  }
}