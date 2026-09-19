
import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/autentication/controllers/logout_controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/personalization/screens/address/adress.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/profile_box.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/setting_box.dart';
import 'package:demo_project/features/personalization/screens/user_profile/personal%20info%20screen.dart';
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
  final dark =THelperFunctions.isDarkMode(context);
  Get.put(LogoutController());
  final userController = Get.find<UserController>();
    return Scaffold(
      
      body: Stack(
        children: [
          Container(
            color: dark? TColors.black : TColors.white,
          ),
          
          SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace, horizontal:  TSizes.sm),
          child: Column(
            children: [
              Obx(() => TProfileHeader(
                
                        name: userController.currentUser.value?.name ?? '',
                        username: 'moohramadan',
                        onEditProfile: () => Get.to(() => const PersonalInfoScreen()),
                      )),

              const SizedBox(height: TSizes.spaceBtwItems),
              /// -- Account Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:  16.0),
                child: Column(
                  
                  children: [
                    
                    TSectionHeading(
                    title: "Account Settings",
                    showActionButton: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                   // My Cart
                TSettingBox(
                  icon: Iconsax.shopping_cart,
                  text: 'My Cart',
                  subText: 'Add, remove products and move to checkout',
                  showSubText: true,
                  onTap: () {},
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                  TSettingBox(
                  icon: Iconsax.safe_home,
                  text: 'My Addresses',
                  subText: 'Set shopping delivery address',
                  showSubText: true,
                  onTap: () => Get.to(() => AdressScreen()),
                ),
               
                 const SizedBox(height: TSizes.spaceBtwItems),
                // My Orders
                TSettingBox(
                  icon: Iconsax.bag_tick,
                  text: 'My Orders',
                  subText: 'In-progress and Completed Orders',
                  showSubText: true,
                  onTap: () {},
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),    
                // My Coupons
                TSettingBox(
                  icon: Iconsax.discount_shape,
                  text: 'My Coupons',
                  subText: 'List of all the discounted coupons',
                  showSubText: true,
                  onTap: () {},
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),
                // Notifications
                TSettingBox(
                  icon: Iconsax.notification,
                  text: 'Notifications',
                  subText: 'Set any kind of notification message',
                  showSubText: true,
                  onTap: () {},
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),
                // Account Privacy
                TSettingBox(
                  icon: Iconsax.security_card,
                  text: 'Account Privacy',
                  subText: 'Manage data usage and connected accounts',
                  showSubText: true,
                  onTap: () {},
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                /// -- App Settings Section
                const SizedBox(height: TSizes.spaceBtwSections),
                TSectionHeading(
                  title: 'App Settings',
                  showActionButton: false,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                
                // Settings
                TSettingBox(
                  icon: Iconsax.menu,
                  text: 'Settings',
                  subText: 'Manage your settings',
                  showSubText: true,
                  onTap: () => Get.to(() => const SettingsScreen()),
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),
                // Appearance & Behaviour
                TSettingBox(
                  icon: Iconsax.settings,
                  text: 'Appearance & Behaviour',
                  subText: 'Customize your app',
                  showSubText: true,
                  onTap: () {},
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),
                // Account Settings
                TSettingBox(
                  icon: Iconsax.personalcard1,
                  text: 'Account Settings',
                  subText: 'Manage your accounts',
                  showSubText: true,
                  onTap: () {},
                ),
                 const SizedBox(height: TSizes.spaceBtwItems),
                // User Balance
                TSettingBox(
                  icon: Iconsax.personalcard,
                  text: 'User Balance',
                  subText: 'View your account balance',
                  showSubText: true,
                  onTap: () {},
                ),
                  ]
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // My Addresses
              
              TRoundedElevatedButton(
  color: TColors.primary, // or whatever your "destructive action" color is
  text: 'Log out',
  ShowIcon: true,
  icon: Icons.logout, 
  onpressed:  () => Get.find<LogoutController>().handleLogout(),

),

            ],
          ),
        ),
      ),
        ],
      )
    );
  }
}
