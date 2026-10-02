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
  const ProductInfoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = addProductController;

    return Container(
      child: Column(
        children: [
          TTextFieldRounded(
            controller: controller.nameController,
            hintText: 'WirelessEarbuds',
            hintTextStyle: Theme.of(context).textTheme.titleMedium,
            labelText: 'Product Name',
            labelStyle: Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark ? TColors.dark : TColors.dark,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          TTextFieldRounded(
            controller: controller.descriptionController,
            hintText: 'Description',
            maxLines: 3,
            hintTextStyle: Theme.of(context).textTheme.titleMedium,
            labelText: 'Description',
            labelStyle: Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark ? TColors.dark : TColors.dark,
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          TSectionHeading(title: 'Pricing', showActionButton: false, fontsize: 2),
          SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: TTextFieldRounded(
                  controller: controller.originalPriceController,
                  hintText: '0.00',
                  hintTextStyle: Theme.of(context).textTheme.titleMedium,
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
                  hintTextStyle: Theme.of(context).textTheme.titleMedium,
                  labelText: 'Sale price',
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  focusedBorderColor: dark ? TColors.dark : TColors.dark,
                ),
              )
            ],
          ),
          SizedBox(height: TSizes.md),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => TDropdownField<String>(
                    labelText: 'Category',
                    hintText: 'Select category',
                    value: controller.selectedCategory.value,
                    items: const [
                      DropdownMenuItem(value: 'Sport', child: Text('Sport')),
                      DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                      DropdownMenuItem(value: 'Phones & Tablets', child: Text('Phones & Tablets')),
                      DropdownMenuItem(value: 'Home & Office', child: Text('Home & Office')),
                      DropdownMenuItem(value: 'Fashion', child: Text('Fashion')),
                      DropdownMenuItem(value: 'Health & Beauty', child: Text('Health & Beauty')),
                      DropdownMenuItem(value: 'Computing', child: Text('Computing')),
                      DropdownMenuItem(value: 'Grocery', child: Text('Grocery')),
                      DropdownMenuItem(value: 'Garden & Outdoors', child: Text('Garden & Outdoors')),
                      DropdownMenuItem(value: 'Automotive', child: Text('Automotive')),
                      DropdownMenuItem(value: 'Audio', child: Text('Audio')),
                      DropdownMenuItem(value: 'Footwear', child: Text('Footwear')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setCategory(value);
                    },
                  ),
                ),
              ),
              SizedBox(width: TSizes.md),
              Expanded(
                child: Obx(
                  () => TDropdownField<String>(
                    labelText: 'Brand',
                    hintText: 'Select Brand',
                    value: controller.selectedBrand.value,
                    items: const [
                      DropdownMenuItem(value: 'Nike', child: Text('Nike')),
                      DropdownMenuItem(value: 'Adidas', child: Text('Adidas')),
                      DropdownMenuItem(value: 'Puma', child: Text('Puma')),
                      DropdownMenuItem(value: 'Apple', child: Text('Apple')),
                      DropdownMenuItem(value: 'Samsung', child: Text('Samsung')),
                      DropdownMenuItem(value: 'Sony', child: Text('Sony')),
                      DropdownMenuItem(value: 'JBL', child: Text('JBL')),
                      DropdownMenuItem(value: 'Xiaomi', child: Text('Xiaomi')),
                      DropdownMenuItem(value: 'Huawei', child: Text('Huawei')),
                      DropdownMenuItem(value: 'HP', child: Text('HP')),
                      DropdownMenuItem(value: 'Dell', child: Text('Dell')),
                      DropdownMenuItem(value: 'Lenovo', child: Text('Lenovo')),
                      DropdownMenuItem(value: 'LG', child: Text('LG')),
                      DropdownMenuItem(value: 'Reebok', child: Text('Reebok')),
                      DropdownMenuItem(value: 'New Balance', child: Text('New Balance')),
                      DropdownMenuItem(value: 'Under Armour', child: Text('Under Armour')),
                      DropdownMenuItem(value: 'Canon', child: Text('Canon')),
                      DropdownMenuItem(value: 'Bose', child: Text('Bose')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setBrand(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.md),

          // ------------------------------------------------------------
          // Variants — colors, sizes (category-dependent), stock per variant
          // ------------------------------------------------------------
          TSectionHeading(title: 'Variants', showActionButton: false, fontsize: 2),
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
          Text('Stock per variant', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: TSizes.spaceBtwItems / 2),
          const VariantStockSection(),

          SizedBox(height: TSizes.md),
          Row(
            children: [
              Expanded(child: TRoundedElevatedButton(onPressed: () {}, text: 'Draft', color: TColors.dark)),
              SizedBox(width: TSizes.xs),
              Expanded(
                flex: 2,
                child: TRoundedElevatedButton(
                  onPressed: () => controller.submitProduct(),
                  text: 'Save',
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