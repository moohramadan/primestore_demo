import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/autentication/controllers/logout_controller.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/setting_box.dart';
import 'package:demo_project/seller_features/shop/screens/add_product/add_product.dart';
import 'package:demo_project/seller_features/shop/screens/seller_catalogue/seller_catalogue.dart';
import 'package:demo_project/seller_features/shop/screens/seller_orders/seller_orders.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/business_details/business_details.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/payout_details/payout_details.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SellerSettingScreen extends StatelessWidget {
  const SellerSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    Get.put(LogoutController());

    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            TSizes.md,
            TSizes.sm,
            TSizes.md,
            TSizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'Store management',
                showActionButton: false,
              ),
             // const SizedBox(height: TSizes.spaceBtwItems),
              Column(
                children: [
                  TSettingBox(
                    icon: Iconsax.box,
                    onTap: () => Get.to(() => const SellerCatalogueScreen()),
                    text: 'Products',
                  ),
                  TSettingBox(
                    icon: Iconsax.receipt_item,
                    text: 'Orders',
                    onTap: () => Get.to(() => const SellerOrdersScreen()),
                  ),
                  TSettingBox(
                    icon: Iconsax.add,
                    text: 'Add product',
                    onTap: () => Get.to(() => const AddProductScreen()),
                  ),
                ],
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'Business settings',
                showActionButton: false,
              ),
              //const SizedBox(height: TSizes.spaceBtwItems),
              Column(
                children: [
                  TSettingBox(
                    icon: Iconsax.shop,
                    text: 'Business details',
                    onTap: () => Get.to(() => const BusinessDetailsScreen()),
                  ),
                  TSettingBox(
                    icon: Iconsax.card,
                    text: 'Payout details',
                    onTap: () => Get.to(() => const PayoutDetailsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'App settings',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Column(
                children: [
                  TSettingBox(
                    icon: Iconsax.notification,
                    text: 'Notifications',
                    onTap: () => Get.snackbar(
                      'Notifications',
                      'Notification settings are not available yet.',
                    ),
                  ),
                  TSettingBox(
                    icon: Iconsax.setting_2,
                    text: 'Appearance',
                    onTap: () => Get.snackbar(
                      'Appearance',
                      'Appearance settings are not available yet.',
                    ),
                  ),
                ],
              ),
              TSettingBox(
                icon: Icons.logout,
                text: 'Log out',
                onTap: () => Get.find<LogoutController>().handleLogout(),
                trailingIcon: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
