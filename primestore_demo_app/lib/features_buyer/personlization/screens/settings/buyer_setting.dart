
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/setting_box.dart';
import 'package:demo_project/features_buyer/autentication/screens/login/login%20screen.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';

class BuyerSettingsScreen extends StatelessWidget {
  const BuyerSettingsScreen({super.key});

   @override
  Widget build(BuildContext context) {
  //final dark =THelperFunctions.isDarkMode(context);
    return Scaffold(
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal:  TSizes.md),
          child: Column(
            
            children: [
             
              const SizedBox(height: TSizes.spaceBtwSections * 2),
              /// -- Account Settings Section
              TSectionHeading(
                fontsize: 14,
                title: "Account",
                showActionButton: false,
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 310,
                     child: Text('Muhammmad Ramadan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis,),),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      Icon(Iconsax.star1, color: TColors.primary, size: 20,),
                      SizedBox(width: 5,),
                      Text('4.85', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  )
                ],
               ),
               CircleAvatar(
                radius: 30,
                backgroundColor: TColors.primary.withValues(alpha: 0.2),
                child: Icon(Iconsax.user, color: TColors.primary, size: 30,),
               )
             ],
             ),
             Divider(
                thickness: 1,),
              const SizedBox(height: TSizes.spaceBtwItems),
              // My Addresses
              TSettingBox(
                icon: Iconsax.safe_home,
                text: 'My Addresses',
                subText: 'Set shopping delivery address',
                showSubText: true,
                onTap: () {},
              ),
              
               const SizedBox(height: TSizes.spaceBtwItems),
              // My Cart
              
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
             Divider(
                thickness: 1,),
              
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
                onTap: () {},
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
              
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => BuyerLoginScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6BFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Logout',
                                  style: TextStyle(fontSize:20, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 9,),
                                Icon(Iconsax.close_square, size: 20,)
                              ],
                            ),
                          ),
                        ),
            ],
          ),
        ),
      
    );
  }
}
