import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';

class PayoutForm extends StatelessWidget {
  const PayoutForm({
    super.key,
    required this.formKey,
    required this.accountHolderController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.routingNumberController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountHolderController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController routingNumberController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TTextFieldRounded(
            controller: accountHolderController,
            icon: Icons.person_outline,
            focusedBorderColor: TColors.primary,
            hintText: 'Account holder name',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                TValidator.validateEmptyText('Account holder name', value),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextFieldRounded(
            controller: bankNameController,
            icon: Icons.account_balance_outlined,
            focusedBorderColor: TColors.primary,
            hintText: 'Bank name',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                TValidator.validateEmptyText('Bank name', value),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextFieldRounded(
            controller: accountNumberController,
            icon: Icons.numbers_outlined,
            focusedBorderColor: TColors.primary,
            hintText: 'Account number',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                TValidator.validateEmptyText('Account number', value),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextFieldRounded(
            controller: routingNumberController,
            icon: Icons.route_outlined,
            focusedBorderColor: TColors.primary,
            hintText: 'Routing number',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                TValidator.validateEmptyText('Routing number', value),
          ),
        ],
      ),
    );
  }
}
