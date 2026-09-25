import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/dropdown.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class ProductInfoContainer extends StatelessWidget {
  const ProductInfoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(

      child: Column(
        children: [
          TTextFieldRounded(
            hintText: 'WirelessEarbuds',
            hintTextStyle: Theme.of(context).textTheme.titleMedium,
            labelText: 'Product Name',
            labelStyle:  Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark? TColors.dark: TColors.dark,
          ),
          SizedBox(height:  TSizes.spaceBtwItems),
          TTextFieldRounded(
            hintText: 'Description',
            maxLines: 3,
            hintTextStyle: Theme.of(context).textTheme.titleMedium,
            labelText: 'Description',
            labelStyle:  Theme.of(context).textTheme.titleMedium,
            focusedBorderColor: dark? TColors.dark: TColors.dark,
          ),
          SizedBox(height:  TSizes.spaceBtwItems),
          TSectionHeading(title: 'Pricing', showActionButton: false, fontsize: 2,),
          SizedBox(height:  TSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: TTextFieldRounded(
                            hintText: '0.00',
                            hintTextStyle: Theme.of(context).textTheme.titleMedium,
                            labelText: 'Original price',
                            labelStyle:  Theme.of(context).textTheme.titleMedium,
                            focusedBorderColor: dark? TColors.dark: TColors.dark,
                          ),
              ),
              SizedBox(width: TSizes.md,),
          Expanded(
            child: TTextFieldRounded(
              hintText: '0.00',
              hintTextStyle: Theme.of(context).textTheme.titleMedium,
              labelText: 'Price',
              labelStyle:  Theme.of(context).textTheme.titleMedium,
              focusedBorderColor: dark? TColors.dark: TColors.dark,
            ),
          )
            ],
          ),
          SizedBox(height: TSizes.md,),
          Row(
            children: [
              Expanded(
                child: TDropdownField<String>(
                  labelText: 'Category',
                  hintText: 'Select category',
                  value: 'Sport',
                  items: [
                    DropdownMenuItem(value: 'Sport', child: Text('Sport',),),
                    DropdownMenuItem(value: 'Electronics', child: Text('Electronics',),),
                  ],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(width: TSizes.md,),
              Expanded(
                child: TDropdownField<String>(
                  labelText: 'Brand',
                  hintText: 'Select Brand',
                  value: 'Nike',
                  items: [
                    DropdownMenuItem(value: 'Nike', child: Text('Nike',),),
                    DropdownMenuItem(value: 'Adidas', child: Text('Adidas',),),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.md,),
          Row(
            children: [
              Expanded( child: TRoundedElevatedButton( onPressed: (){}, text: 'Draft', color: TColors.dark,)),
              SizedBox(width: TSizes.xs,),
              Expanded(flex: 2, child: TRoundedElevatedButton( onPressed: (){}, text: 'Save')),
            ],
          ),
          SizedBox(height: TSizes.md,),
          

        ],
      ),
    );
  }
}