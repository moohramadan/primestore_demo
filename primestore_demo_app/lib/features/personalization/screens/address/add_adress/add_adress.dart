import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/features/personalization/controllers/add_address_controller.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class AddAdressScreen extends StatelessWidget {
  const AddAdressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AddAddressController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             
              TTextFieldRounded(
                labelText: 'Full name',
                hintText: 'Enter your full name',
                icon: Icons.person_outline,
                controller: controller.fullNameController,
                validator: (value) => TValidator.validateEmptyText('Full name', value),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TTextFieldRounded(
                labelText: 'Phone',
                hintText: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: controller.phoneController,
                validator: (value) => TValidator.validateEmptyText('Phone', value),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TTextFieldRounded(
                labelText: 'Address line 1',
                hintText: 'Street address',
                icon: Icons.home_outlined,
                controller: controller.addressLine1Controller,
                validator: (value) => TValidator.validateEmptyText('Address line 1', value),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TTextFieldRounded(
                labelText: 'Address line 2',
                hintText: 'Apartment, suite, or unit (optional)',
                controller: controller.addressLine2Controller,
                icon: Icons.apartment_outlined,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TTextFieldRounded(
                labelText: 'City',
                hintText: 'Enter your city',
                icon: Icons.location_city_outlined,
                controller: controller.cityController,
                validator: (value) => TValidator.validateEmptyText('City', value),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              Row(
                children: [
                  Expanded(
                    child: TTextFieldRounded(
                      labelText: 'State',
                      hintText: 'State',
                      controller: controller.stateController,
                      validator: (value) => TValidator.validateEmptyText('State', value),
                    ),
                  ),
                  const SizedBox(width: TSizes.md),
                  Expanded(
                    child: TTextFieldRounded(
                      labelText: 'Postal code',
                      hintText: 'Postal code',
                      controller: controller.postalCodeController,
                      validator: (value) => TValidator.validateEmptyText('Postal code', value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TTextFieldRounded(
                labelText: 'Country',
                hintText: 'Enter your country',
                icon: Icons.public_outlined,
                controller: controller.countryController,
                validator: (value) => TValidator.validateEmptyText('Country', value),
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
Obx(
  () => TRoundedElevatedButton(
    text: controller.isLoading.value ? 'Saving...' : 'Save address',
    onPressed: controller.isLoading.value ? null : () => controller.saveAddress(),
    color: dark ? TColors.white : TColors.black,
    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: dark ? TColors.black : TColors.white,
        ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}