import 'dart:convert';

import 'package:demo_project/data/models/seller_profile.dart';
import 'package:demo_project/seller_features/autentication/models/seller_signup_data.dart';
import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class SellerRepository {
  Future<SellerProfile?> getSellerProfile() async {
    final accessToken = await SecureStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Please sign in to check your seller profile.');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/seller/profile'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw _responseError(response, 'Could not load seller profile');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['seller_profile'] is! Map<String, dynamic>) {
      throw const FormatException('The seller profile response is invalid.');
    }

    return SellerProfile.fromJson(
      decoded['seller_profile'] as Map<String, dynamic>,
    );
  }

  Future<void> createSellerProfile({
    required SellerSignupData signupData,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
  }) async {
    final accessToken = await SecureStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(
        'Please sign in again before creating a seller account.',
      );
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/seller/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'account_type': signupData.accountType,
        'business_name': signupData.businessName,
        'business_phone': signupData.businessPhone,
        'business_address': signupData.businessAddress,
        'account_holder_name': accountHolderName,
        'bank_name': bankName,
        'account_number': accountNumber,
      }),
    );

    if (response.statusCode == 201) return;
    throw _responseError(response, 'Could not create seller account');
  }

  Exception _responseError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      final message = body is Map<String, dynamic> && body['error'] is String
          ? body['error'] as String
          : '$fallback (HTTP ${response.statusCode}).';
      return Exception(message);
    } on FormatException {
      return Exception('$fallback (HTTP ${response.statusCode}).');
    }
  }
}
