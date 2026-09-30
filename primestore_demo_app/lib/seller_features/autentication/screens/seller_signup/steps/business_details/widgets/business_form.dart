import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';

class BusinessForm extends StatelessWidget {
	const BusinessForm({
		super.key,
		required this.formKey,
		required this.businessNameController,
		required this.phoneNumberController,
		required this.addressController,
	});

	final GlobalKey<FormState> formKey;
	final TextEditingController businessNameController;
	final TextEditingController phoneNumberController;
	final TextEditingController addressController;

	@override
	Widget build(BuildContext context) {
		return Form(
			key: formKey,
			child: Column(
				children: [
					TTextFieldRounded(
						controller: businessNameController,
						icon: Icons.store_outlined,
						focusedBorderColor: TColors.primary,
						hintText: 'Enter your business name',
						textInputAction: TextInputAction.next,
						validator: (value) =>
								TValidator.validateEmptyText('Business name', value),
					),
					const SizedBox(height: TSizes.spaceBtwInputFields),
					TTextFieldRounded(
						controller: phoneNumberController,
						icon: Icons.phone_outlined,
						focusedBorderColor: TColors.primary,
						hintText: 'Enter your business phone number',
						keyboardType: TextInputType.phone,
						textInputAction: TextInputAction.done,
						validator: TValidator.validatePhoneNumber,
					),
          const SizedBox(height: TSizes.spaceBtwInputFields),
					TTextFieldRounded(
						controller: addressController,
						icon: Icons.location_on_outlined,
						focusedBorderColor: TColors.primary,
						hintText: 'Enter your business address',
						keyboardType: TextInputType.streetAddress,
						textInputAction: TextInputAction.done,
						validator: (value) =>
								TValidator.validateEmptyText('Business address', value),
					)
				],
			),
		);
	}
}
