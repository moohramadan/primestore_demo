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
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountHolderController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;

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
                _validateMaxLength(value, 'Account holder name', 150),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextFieldRounded(
            controller: bankNameController,
            icon: Icons.account_balance_outlined,
            focusedBorderColor: TColors.primary,
            hintText: 'Bank name',
            textInputAction: TextInputAction.next,
            validator: (value) => _validateMaxLength(value, 'Bank name', 100),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TTextFieldRounded(
            controller: accountNumberController,
            icon: Icons.numbers_outlined,
            focusedBorderColor: TColors.primary,
            hintText: 'Account number',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final requiredError = TValidator.validateEmptyText(
                'Account number',
                value,
              );
              if (requiredError != null) return requiredError;
              if (!RegExp(r'^\d{6,20}$').hasMatch(value!.trim())) {
                return 'Enter an account number with 6 to 20 digits.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  String? _validateMaxLength(String? value, String fieldName, int maxLength) {
    final requiredError = TValidator.validateEmptyText(fieldName, value);
    if (requiredError != null) return requiredError;
    if (value!.trim().length > maxLength) {
      return '$fieldName must be $maxLength characters or fewer.';
    }
    return null;
  }
}
