class TPlatformException implements Exception {
  final String code;

  TPlatformException(this.code);

  String get message {
    switch (code) {
      case 'network_error':
        return 'Network error. Please check your internet connection.';
      case 'device_not_supported':
        return 'This feature is not supported on your device.';
      case 'permission_denied':
        return 'Permission denied. Please grant the required permissions in settings.';
      case 'location_permission_denied':
        return 'Location permission denied. Please enable it in settings.';
      case 'camera_permission_denied':
        return 'Camera permission denied. Please enable it in settings.';
      case 'microphone_permission_denied':
        return 'Microphone permission denied. Please enable it in settings.';
      case 'storage_permission_denied':
        return 'Storage permission denied. Please enable it in settings.';
      case 'biometric_permission_denied':
        return 'Biometric permission denied. Please enable it in settings.';
      case 'notification_permission_denied':
        return 'Notification permission denied. Please enable it in settings.';
      case 'file_not_found':
        return 'The requested file was not found.';
      case 'storage_full':
        return 'Device storage is full. Please free up some space.';
      case 'insufficient_storage':
        return 'Insufficient storage available. Please free up some space.';
      case 'memory_insufficient':
        return 'Insufficient memory. Please close some apps and try again.';
      case 'operation_timeout':
        return 'Operation timed out. Please try again.';
      case 'authentication_failed':
        return 'Authentication failed. Please try again.';
      case 'invalid_credentials':
        return 'Invalid credentials. Please check your input.';
      case 'session_expired':
        return 'Your session has expired. Please log in again.';
      case 'unauthorized_access':
        return 'You do not have permission to access this resource.';
      case 'invalid_argument':
        return 'Invalid argument provided. Please check your input.';
      case 'operation_not_allowed':
        return 'This operation is not allowed on this platform.';
      case 'platform_not_available':
        return 'This platform or feature is not available.';
      case 'camera_unavailable':
        return 'Camera is not available on this device.';
      case 'biometric_unavailable':
        return 'Biometric authentication is not available on this device.';
      case 'nfc_unavailable':
        return 'NFC is not available on this device.';
      case 'gps_unavailable':
        return 'GPS is not available on this device.';
      case 'bluetooth_unavailable':
        return 'Bluetooth is not available on this device.';
      case 'battery_low':
        return 'Battery is low. Please charge your device.';
      case 'battery_critical':
        return 'Battery is critically low. Please charge your device immediately.';
      case 'device_offline':
        return 'Device is offline. Please check your connection.';
      case 'failed_to_initialize':
        return 'Failed to initialize the platform module.';
      case 'method_not_implemented':
        return 'This method is not implemented on this platform.';
      case 'unexpected_error':
        return 'An unexpected platform error occurred.';
      case 'plugin_not_found':
        return 'Required plugin is not found or not initialized.';
      case 'permission_handler_error':
        return 'Permission handler error occurred.';
      case 'location_service_disabled':
        return 'Location service is disabled. Please enable it in settings.';
      case 'bluetooth_disabled':
        return 'Bluetooth is disabled. Please enable it in settings.';
      case 'wifi_disabled':
        return 'WiFi is disabled. Please enable it in settings.';
      case 'airplane_mode_enabled':
        return 'Airplane mode is enabled. Please disable it.';
      case 'device_locked':
        return 'Device is locked. Please unlock it.';
      case 'screen_lock_required':
        return 'Screen lock is required for this operation.';
      case 'pin_code_required':
        return 'PIN code is required for this operation.';
      case 'biometric_failed':
        return 'Biometric authentication failed. Please try again.';
      case 'database_error':
        return 'Database error occurred. Please try again.';
      case 'file_read_error':
        return 'Failed to read file. Please try again.';
      case 'file_write_error':
        return 'Failed to write file. Please try again.';
      case 'shared_preferences_error':
        return 'Failed to access shared preferences.';
      case 'encoding_error':
        return 'Encoding error occurred. Please try again.';
      case 'decoding_error':
        return 'Decoding error occurred. Please try again.';
      case 'unsupported_format':
        return 'Unsupported file format.';
      case 'version_mismatch':
        return 'Version mismatch. Please update the app.';
      case 'remote_service_unavailable':
        return 'Remote service is currently unavailable. Please try later.';
      default:
        return 'A platform error occurred. Please try again.';
    }
  }
}