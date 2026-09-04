import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:demo_project/utils/popups/loaders.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Manages the network connectivity status and provides methods to check and
/// handle connectivity changes.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  @override
  void onInit() {
    super.onInit();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Update the connection status based on connectivity changes.
  Future<void> _updateConnectionStatus(
      List<ConnectivityResult> result) async {
    _connectionStatus.value = result;

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      TLoaders.warningSnackBar(
        title: 'No Internet Connection',
      );
    }
  }

  /// Check whether the device is connected to the internet.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.none)) {
        return false;
      }

      return true;
    } on PlatformException {
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}