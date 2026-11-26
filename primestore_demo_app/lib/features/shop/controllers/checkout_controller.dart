import 'dart:math';

import 'package:demo_project/data/repositories/address_repository.dart';
import 'package:demo_project/data/repositories/checkout_repository.dart';
import 'package:demo_project/features/personalization/models/address_model.dart';
import 'package:demo_project/features/personalization/screens/address/add_adress/add_adress.dart';
import 'package:demo_project/features/shop/controllers/cart_controller.dart';
import 'package:demo_project/features/shop/models/order_model.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final _addressRepository = AddressController();
  final _checkoutRepository = CheckoutRepository();
  final _cartController = Get.find<CartController>();

  final addresses = <AddressModel>[].obs;
  final selectedAddressId = RxnInt();
  final isLoadingAddresses = false.obs;
  final isPlacingOrder = false.obs;
  final order = Rxn<OrderModel>();
  final addressError = RxnString();

  String? _idempotencyKey;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  AddressModel? get selectedAddress {
    final id = selectedAddressId.value;
    if (id == null) return null;
    for (final address in addresses) {
      if (address.id == id) return address;
    }
    return null;
  }

  Future<void> fetchAddresses() async {
    isLoadingAddresses.value = true;
    addressError.value = null;
    try {
      final result = await _addressRepository.getAddresses();
      addresses.assignAll(result);
      if (selectedAddressId.value == null ||
          !result.any((address) => address.id == selectedAddressId.value)) {
        final defaultAddress = result.where((address) => address.isDefault);
        selectedAddressId.value = defaultAddress.isEmpty
            ? (result.isEmpty ? null : result.first.id)
            : defaultAddress.first.id;
      }
    } catch (error) {
      addressError.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  void selectAddress(int? id) {
    if (selectedAddressId.value != id) {
      selectedAddressId.value = id;
      _idempotencyKey = null;
    }
  }

  Future<void> addAddress() async {
    await Get.to(() => const AddAdressScreen());
    await fetchAddresses();
  }

  Future<void> placeOrder() async {
    if (isPlacingOrder.value || order.value != null) return;
    final addressId = selectedAddressId.value;
    if (addressId == null) {
      Get.snackbar('Checkout', 'Add or select a delivery address');
      return;
    }
    if (_cartController.isEmpty) {
      Get.snackbar('Checkout', 'Your cart is empty');
      return;
    }
    if (_cartController.hasUnavailableItems) {
      Get.snackbar('Checkout', 'Remove items that are out of stock first');
      return;
    }

    isPlacingOrder.value = true;
    try {
      _idempotencyKey ??= _newIdempotencyKey();
      order.value = await _checkoutRepository.placeOrder(
        addressId: addressId,
        idempotencyKey: _idempotencyKey!,
      );
      _idempotencyKey = null;
      _cartController.clearLocal();
      await _cartController.fetchCart();
    } catch (error) {
      Get.snackbar(
        'Could not place order',
        error.toString().replaceFirst('Exception: ', ''),
        duration: const Duration(seconds: 5),
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  String _newIdempotencyKey() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
