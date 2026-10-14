import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlassLoginSlider extends StatelessWidget {
  const GlassLoginSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.find<GlassSlideController>();
    //final dark= THelperFunctions.isDarkMode(context);

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TSizes.md),
          color:dark? TColors.darkerGrey:TColors.grey
        ),
        width: 300,
        height: 50,
        padding: const EdgeInsets.all(4),
       
        child: Stack(
          children: [
            // Sliding background
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: controller.isEmail.value? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 146, // roughly half of 300 - padding
                height: double.infinity,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Tabs
            Row(
              children: [
                // Email
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.isEmail.value = true,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'Email',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: TColors.white,
                              fontWeight:  FontWeight.w600 ,
                            ),
                      ),
                    ),
                  ),
                ),

                // Phone Number
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.isEmail.value = false,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'Phone Number',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: TColors.white,
                              fontWeight:  FontWeight.w600 ,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class GlassSlideController extends GetxController {
  final RxBool isEmail = true.obs;

  void switchToEmail() => isEmail.value = true;
  void switchToPhone() => isEmail.value = false;
}