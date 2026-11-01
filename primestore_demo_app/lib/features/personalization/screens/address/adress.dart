import 'package:demo_project/common/widgets/effects/shimmer_effect.dart';
import 'package:demo_project/features/personalization/controllers/add_address_controller.dart';
import 'package:demo_project/features/personalization/screens/address/add_adress/add_adress.dart';
import 'package:demo_project/features/personalization/screens/address/widgets/adress_box.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressListController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: dark ? TColors.white : TColors.dark),
        title: const Text('My addresses'),

        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () async {
              await Get.to(() => const AddAdressScreen());
              controller.fetchAddresses();
            },
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const _AddressListShimmer();
        }

        if (controller.addresses.isEmpty) {
          return const Center(child: Text('No addresses saved yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
              child: TAdressbox(
                name: address.fullName,
                adress: address.addressLine1,
                state: address.state,
                phoneNumber: address.phone,
                isDefault: address.isDefault,
                onTap: () {
                  controller.setDefault(address.id);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class _AddressListShimmer extends StatelessWidget {
  const _AddressListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: 4,
      separatorBuilder: (context, index) =>
          const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) => const _AddressShimmerCard(),
    );
  }
}

class _AddressShimmerCard extends StatelessWidget {
  const _AddressShimmerCard();

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : const Color(0xFFF6F6F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? TColors.darkGrey
              : TColors.black.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.58,
            child: TShimmerEffect(
              width: double.infinity,
              height: 20,
              radius: 4,
            ),
          ),
          SizedBox(height: TSizes.xs),
          TShimmerEffect(width: double.infinity, height: 14, radius: 4),
          SizedBox(height: 6),
          FractionallySizedBox(
            widthFactor: 0.72,
            child: TShimmerEffect(
              width: double.infinity,
              height: 14,
              radius: 4,
            ),
          ),
          SizedBox(height: TSizes.sm),
          FractionallySizedBox(
            widthFactor: 0.42,
            child: TShimmerEffect(
              width: double.infinity,
              height: 14,
              radius: 4,
            ),
          ),
          TShimmerEffect(width: 150, height: 14, radius: 4),
        ],
      ),
    );
  }
}
