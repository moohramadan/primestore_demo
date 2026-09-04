import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSlider extends StatelessWidget {
  const LoginSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SlideController>();
    final dark= THelperFunctions.isDarkMode(context);

    return Obx(
      () => Container(
        width: 300,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: dark? TColors.secondaryDark:TColors.secondary,
        ),
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
                  borderRadius: BorderRadius.circular(22),
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


class SlideController extends GetxController {
  final RxBool isEmail = true.obs;

  void switchToEmail() => isEmail.value = true;
  void switchToPhone() => isEmail.value = false;
}