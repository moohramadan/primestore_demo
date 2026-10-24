import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/features/autentication/controllers/logout_controller.dart';
import 'package:demo_project/features/autentication/screens/onboarding/screens/onboarding1/onboarding1.dart';
import 'package:demo_project/features/personalization/screens/address/adress.dart';
import 'package:demo_project/features/personalization/screens/setting/widgets/setting_box.dart';
import 'package:demo_project/features/personalization/screens/user_profile/personal%20info%20screen.dart';
import 'package:demo_project/data/models/seller_profile.dart';
import 'package:demo_project/data/repositories/seller_repository.dart';
import 'package:demo_project/navigation/seller_nav.dart';
import 'package:demo_project/seller_features/autentication/screens/onboarding/onboarding.dart';
import 'package:demo_project/utils/constants/colors.dart';

import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _sellerRepository = SellerRepository();
  late Future<SellerProfile?> _sellerProfileFuture;

  @override
  void initState() {
    super.initState();
    _sellerProfileFuture = _sellerRepository.getSellerProfile();
  }

  void _retrySellerProfileCheck() {
    setState(() {
      _sellerProfileFuture = _sellerRepository.getSellerProfile();
    });
  }

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
                text: 'Onboarding',
                onTap: () => Get.to(() => Onboarding1()),
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
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(
                fontsize: TSizes.xs - 5,
                title: 'switch accounts',
                showActionButton: false,
              ),
            
             FutureBuilder<SellerProfile?>(
                future: _sellerProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const TSettingBox(
                      icon: Iconsax.shop,
                      text: 'Checking seller profile',
                      onTap: null,
                      trailingIcon: null,
                    );
                  }

                  if (snapshot.hasError) {
                    return TSettingBox(
                      icon: Iconsax.shop,
                      text: 'Could not check seller profile',
                      subText: 'Tap to try again',
                      onTap: _retrySellerProfileCheck,
                    );
                  }

                  final sellerProfile = snapshot.data;
                  if (sellerProfile == null) {
                    return TSettingBox(
                      icon: Iconsax.shop,
                      text: 'Become a seller',
                      onTap: () => Get.to(() => const ONBoardingScreen()),
                    );
                  }

                  return TSettingBox(
                    icon: Iconsax.shop,
                    text: sellerProfile.businessName,
                    subText: sellerProfile.formattedAccountType,
                    onTap: () => Get.to(() => const SellerNavigationMenu()),
                  );
                },
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
