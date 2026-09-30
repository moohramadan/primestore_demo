import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditNameScreen extends StatelessWidget {
  EditNameScreen({super.key});

  final controller = Get.put(EditNameController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark ? TColors.black : TColors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: dark ? TColors.white : Colors.black),
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: 6),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'This is the name you would like other people to use '
                'when referring to you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TTextFieldRounded(
                controller: controller.nameController,
                hintText: 'Enter new name',
                textInputAction: TextInputAction.done,
                validator: (value) => TValidator.validateEmptyText('Name', value),
                hintTextStyle: TextStyle(fontSize: TSizes.md),
              ),
              const Spacer(),
              TRoundedElevatedButton(
                onPressed: () {},
                text: 'Update',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditNameController extends GetxController {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}