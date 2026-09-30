import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/autentication/controllers/logout_controller.dart';
import 'package:demo_project/features/personalization/screens/address/adress.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/setting_box.dart';
import 'package:demo_project/features/personalization/screens/user_profile/personal%20info%20screen.dart';
import 'package:demo_project/seller_features/autentication/screens/onboarding/onboarding.dart';
import 'package:demo_project/utils/constants/colors.dart';

import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    Get.put(LogoutController());

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.white,
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
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: ' Your account',
                showActionButton: false,
              ),
              TSettingBox(
                    icon: Iconsax.user,
                    text: 'Account centre',
                    subText: "Password, security, personal details",
                    showSubText: true,
                    onTap: () => Get.to(() => const PersonalInfoScreen()),
                  ),
               const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'Shopping',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TSettingBox(
                    icon: Iconsax.safe_home,
                    text: 'My Addresses',
                    onTap: () => Get.to(() => AddressScreen()),
                  ),
                  TSettingBox(
                    icon: Iconsax.security_card,
                    text: 'Account Privacy',
                    onTap: () {},
                  ),
              TSettingBox(
                    icon: Iconsax.shopping_cart,
                    text: 'My Cart',
                    onTap: () {},
                  ),
                  TSettingBox(
                    icon: Iconsax.bag_tick,
                    text: 'My Orders',
                    onTap: () {},
                  ),
                  TSettingBox(
                    icon: Iconsax.discount_shape,
                    text: 'My Coupons',
                    onTap: () {},
                  ),
              const SizedBox(height: TSizes.spaceBtwSections),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'App settings',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TSettingBox(
                    icon: Iconsax.notification,
                    text: 'Notifications',
                    onTap: () {},
                  ),
                  TSettingBox(
                    icon: Iconsax.setting_2,
                    text: 'Appearance & Behaviour',
                    onTap: () {},
                  ),
                  TSettingBox(
                    icon: Iconsax.shop,
                    text: 'Become a seller',
                    onTap: () => Get.to(() => ONBoardingScreen()),
                  ),
              TSettingBox(
                    icon: Icons.logout,
                    text: 'Log out',
                    trailingIcon: null,
                    onTap: () => Get.find<LogoutController>().handleLogout(),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

