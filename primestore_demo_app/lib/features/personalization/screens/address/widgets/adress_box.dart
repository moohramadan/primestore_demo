import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:iconsax/iconsax.dart';

class TAdressbox extends StatelessWidget {
  const TAdressbox({
    super.key,
    required this.name,
    required this.adress,
    required this.state,
    required this.phoneNumber,
  });

  final String name;
  final String adress;
  final String state;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : const Color(0xFFF6F6F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? TColors.darkGrey : TColors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: dark ? TColors.white : TColors.black,
                    fontSizeDelta: 2,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              adress,
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: dark ? TColors.white : TColors.black,
                    fontSizeDelta: -2,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              state,
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: dark ? TColors.white : TColors.black,
                    fontSizeDelta: -3,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              phoneNumber,
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: dark ? TColors.white : TColors.black,
                    fontSizeDelta: -3,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
