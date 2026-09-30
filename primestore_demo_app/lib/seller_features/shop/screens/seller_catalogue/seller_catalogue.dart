import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/indicator_container.dart';
import 'package:demo_project/common/widgets/list_title/product_tile.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/add_product.dart';
import 'package:demo_project/seller_features/shop/screens/seller_catalogue/widgets/categories_row.dart';
import 'package:demo_project/seller_features/shop/screens/seller_product_details/seller_product_detai;s.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class SellerCatalogueScreen extends StatelessWidget {
  const SellerCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:  TSizes.defaultSpace, vertical:TSizes.defaultSpace, ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TSectionHeading(title: "Products", showActionButton: false, fontsize: TSizes.md -2,),
                  //SizedBox(width: 170,),
                  GestureDetector(
                    onTap: () => Get.to(() => AddProductScreen()),
                    child: TRoundedContainer(
                      radius: 40,
                      padding: EdgeInsets.symmetric(vertical:  TSizes.sm + 2, horizontal: TSizes.md ),
                      backgroundColor:dark? TColors.darkerGrey: TColors.black,
                      child: Row(children: [
                        Icon(Icons.add,color: TColors.white,),
                        SizedBox(width: 5,),
                        Text('Add', style: Theme.of(context).textTheme.titleSmall!.apply(color: TColors.white))
                      ],),
                    ),
                  ),
                ],
              ),
              //SizedBox(height: TSizes.spaceBtwItems,),
              Text('10 in catalogue', style: Theme.of(context).textTheme.labelMedium!.apply(fontSizeDelta: TSizes.sm - 4),),
              SizedBox(height: TSizes.spaceBtwItems,),
              TSearchBox(),
              SizedBox(height: TSizes.spaceBtwItems,),
              TCatalogueCategories(),
              SizedBox(height: TSizes.spaceBtwItems + 10,),
              Container(
                width: double.infinity,
                
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: [
                    GestureDetector
                    (
                      onTap: () => Get.to(() => SellerProductDetail()),
                      child: TProductTile(
                        title: 'Classic Leather Chair',
                        subtitle: 'Furniture',
                        price: '149.00',
                        icon: Iconsax.lamp_on,
                        status: TIndicatorStatus.active,
                      ),
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Minimal Desk Lamp',
                      subtitle: 'Home Decor',
                      price: '74.50',
                      icon: Iconsax.lamp,
                      status: TIndicatorStatus.draft,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Smart Watch Pro',
                      subtitle: 'Electronics',
                      price: '249.99',
                      icon: Iconsax.watch,
                      status: TIndicatorStatus.active,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Premium Coffee Set',
                      subtitle: 'Kitchen',
                      price: '89.00',
                      icon: Iconsax.cup,
                      status: TIndicatorStatus.notActive,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Travel Backpack',
                      subtitle: 'Accessories',
                      price: '120.00',
                      icon: Iconsax.bag,
                      status: TIndicatorStatus.active,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Wireless Earbuds',
                      subtitle: 'Audio',
                      price: '99.99',
                      icon: Iconsax.headphone,
                      status: TIndicatorStatus.draft,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields,),
                    TProductTile(
                      title: 'Ceramic Vase',
                      subtitle: 'Decor',
                      price: '58.75',
                      icon: Iconsax.gift,
                      status: TIndicatorStatus.active,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

