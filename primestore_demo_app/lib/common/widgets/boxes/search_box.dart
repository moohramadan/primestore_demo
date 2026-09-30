import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


class TSearchBox extends StatelessWidget {
  const TSearchBox({
    super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: TSizes.xl, vertical: TSizes.md),
        hintText: 'Search',
        hintStyle: Theme.of(context).textTheme.bodySmall!.apply(fontSizeDelta: 2, ),
        prefixIcon: const Icon(Iconsax.search_normal),
        filled: true,
        fillColor: dark? TColors.darkerGrey: TColors.grey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusXxl + 20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusXxl + 20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusXxl + 20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}