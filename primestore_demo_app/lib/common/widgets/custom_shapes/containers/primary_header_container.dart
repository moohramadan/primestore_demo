
//import 'package:demo_project/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:demo_project/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key, required this.child, this.height = 400
  });

  final Widget child;
  final double ? height;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return TCurvedEdgesWidget(
      child: Container(
        height: height,
        color:  dark ?  TColors.scaffoldDarkBlue1: TColors.white,
        padding: EdgeInsets.zero,
        child: SizedBox(
          
          child: Stack(
            children: [
              // Decorative circular shapes positioned off-canvas
              
             
              // Ensure the provided child is rendered above the decorative shapes
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


