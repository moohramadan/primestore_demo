import 'package:demo_project/common/widgets/layouts/grid_layout.dart';
import 'package:demo_project/common/widgets/texts/rounded_text.dart';
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

    return Scaffold(
      appBar: AppBar(
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
          return const Center(child: CircularProgressIndicator());
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
      ),
    );
  },
);

      }),
    );
  }
}

