import 'package:demo_project/features/personalization/screens/address/adress_box.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';


class AdressScreen extends StatelessWidget {
  const AdressScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final dark = THelperFunctions.isDarkMode(context);
     final controller = Get.put(SeclectedaddressController());
    return Scaffold(
      backgroundColor:  dark?TColors.black:  Color(0xFFF6F6F1),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
         
          children: [
            TAdressbox(
              name: 'Muhammad Ramadan',
              adress: 'Naf Valley Housing Estate',
              state: 'Fct Abuja',
              phoneNumber: '+234 8037566796', id: '1',
            ),
            SizedBox(height:  TSizes.spaceBtwInputFields),
            TAdressbox(
              name: 'Muhammad Ramadan',
              adress: 'Naf Valley Housing Estate',
              state: 'Fct Abuja',
              phoneNumber: '+234 8037566796', id: '2',
            ),
            SizedBox(height:  TSizes.spaceBtwInputFields),
            TAdressbox(
              name: 'Muhammad Ramadan',
              adress: 'Naf Valley Housing Estate',
              state: 'Fct Abuja',
              phoneNumber: '+234 8037566796', id: '3',
            ),
          ],
        ),
      ),
    );
  }
}

