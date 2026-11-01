import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/dropdown.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/autentication/controllers/add_product_controller.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/color_chip_picker.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/size_chip_picker.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/widgets/variant_stock_section.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductInfoContainer extends StatelessWidget {
  const ProductInfoContainer({
    super.key,
    required this.onSave,
    required this.isSaving,
  });

  final Future<void> Function() onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = addProductController;
    final hintStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: dark ? Colors.white54 : Colors.black45,
    );

    return Container(
      child: Column(
        children: [
          TTextFieldRounded(
            controller: controller.nameController,
            hintText: 'WirelessEarbuds',
            hintTextStyle: hintStyle,
            labelText: 'Product Name',
            labelStyle: Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark ? TColors.dark : TColors.dark,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          TTextFieldRounded(
            controller: controller.descriptionController,
            hintText: 'Description',
            maxLines: 3,
            hintTextStyle: hintStyle,
            labelText: 'Description',
            labelStyle: Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark ? TColors.dark : TColors.dark,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          TSectionHeading(
            title: 'Pricing',
            showActionButton: false,
            fontsize: 2,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: TTextFieldRounded(
                  controller: controller.originalPriceController,
                  hintText: '0.00',
                  hintTextStyle: hintStyle,
                  labelText: 'Original price',
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  focusedBorderColor: dark ? TColors.dark : TColors.dark,
                ),
              ),
              SizedBox(width: TSizes.md),
              Expanded(
                child: TTextFieldRounded(
                  controller: controller.salePriceController,
                  hintText: '0.00',
                  hintTextStyle: hintStyle,
                  labelText: 'Sale price',
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  focusedBorderColor: dark ? TColors.dark : TColors.dark,
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.md),
          Obx(() {
            if (controller.isLoadingProductOptions.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.productOptionsError.value != null) {
              return Column(
                children: [
                  Text(controller.productOptionsError.value!),
                  TextButton(
                    onPressed: controller.loadProductOptions,
                    child: const Text('Retry loading categories and brands'),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: TDropdownField<int>(
                    labelText: 'Category',
                    hintText: 'Select category',
                    value: controller.selectedCategoryId.value,
                    items: [
                      for (final category in controller.categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setCategory(value);
                    },
                  ),
                ),
                SizedBox(width: TSizes.md),
                Expanded(
                  child: TDropdownField<int>(
                    labelText: 'Brand',
                    hintText: 'Select brand',
                    value: controller.selectedBrandId.value ?? 0,
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('No brand')),
                      for (final brand in controller.brands)
                        DropdownMenuItem(
                          value: brand.id,
                          child: Text(brand.name),
                        ),
                    ],
                    onChanged: controller.setBrand,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: TSizes.md),

          // ------------------------------------------------------------
          // Variants — colors, sizes (category-dependent), stock per variant
          // ------------------------------------------------------------
          TSectionHeading(
            title: 'Variants',
            showActionButton: false,
            fontsize: 2,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          Text('Colors', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: TSizes.spaceBtwItems / 2),
          const ColorVariantSection(),
          SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (!controller.needsSize) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sizes', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: TSizes.spaceBtwItems / 2),
                const SizeVariantSection(),
                SizedBox(height: TSizes.spaceBtwItems),
              ],
            );
          }),
          Text(
            'Stock per variant',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: TSizes.spaceBtwItems / 2),
          const VariantStockSection(),

          SizedBox(height: TSizes.md),
          Row(
            children: [
              Expanded(
                child: TRoundedElevatedButton(
                  onPressed: () => onSave(),
                  text: 'Save',
                  isLoading: isSaving,
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.md),
        ],
      ),
    );
  }
}
