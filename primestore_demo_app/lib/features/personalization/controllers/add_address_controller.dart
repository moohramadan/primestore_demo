import 'package:demo_project/data/repositories/address_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/personalization/models/address_model.dart';
import 'package:demo_project/features/personalization/screens/address/adress.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AddAddressController extends GetxController {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();
  final _addressController = AddressController();
  final _userController = Get.find<UserController>();


  final isLoading = false.obs; // or however you track loading elsewhere

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
   
    try{
      await _addressController.createAddress(
        accessToken: _userController.accessToken.value, 
        fullName: fullNameController.text, 
        phone: phoneController.text, 
        addressLine1: addressLine1Controller.text, 
        addressLine2: addressLine2Controller.text.isEmpty ? null : addressLine2Controller.text,
        city: cityController.text, 
        state: stateController.text, 
        postalCode: postalCodeController.text, 
        country: countryController.text
        );
        Get.snackbar('Success', 'Address added');
        Get.to(()=> AddressScreen());
    }catch (e){
      Get.snackbar('Error', e.toString());
    }finally{
      isLoading.value = false;
    }
    
  }

  @override
  void onClose() {
   fullNameController.dispose();
   phoneController.dispose();
   addressLine1Controller.dispose();
   addressLine2Controller.dispose();
   cityController.dispose();
   stateController.dispose();
   postalCodeController.dispose();
   countryController.dispose();
    super.onClose();
  }
}
class AddressListController extends GetxController {
  final _addressController = AddressController();
  final _userController = Get.find<UserController>();

  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final result = await _addressController.getAddresses(_userController.accessToken.value);
      addresses.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

