import 'dart:convert';

import 'package:demo_project/data/repositories/authenticated_http_client.dart';
import 'package:demo_project/features/personalization/models/address_model.dart';
import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AddressController {
  final AuthenticatedHttpClient _authenticatedClient =
      AuthenticatedHttpClient();

  Future<AddressModel> createAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.post(
        Uri.parse('${ApiConstants.baseUrl}/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'full_name': fullName,
          'phone': phone,
          'address_line_1': addressLine1,
          'address_line_2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        }),
      ),
    );

    if (response.statusCode != 201) {
      throw Exception(_responseMessage(response, 'Adding address failed'));
    }

    final decoded = _decodeObject(response);
    final address = decoded['address'];
    if (address is! Map<String, dynamic>) {
      throw const FormatException('The server returned an invalid address.');
    }
    return AddressModel.fromJson(address);
  }

  Future<List<AddressModel>> getAddresses() async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.get(
        Uri.parse('${ApiConstants.baseUrl}/addresses'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(_responseMessage(response, 'Failed to load addresses'));
    }

    final decoded = _decodeObject(response);
    final addresses = decoded['addresses'];
    if (addresses is! List) {
      throw const FormatException('The server returned invalid addresses.');
    }
    return addresses.map((address) {
      if (address is! Map<String, dynamic>) {
        throw const FormatException('The server returned invalid addresses.');
      }
      return AddressModel.fromJson(address);
    }).toList();
  }

  Future<void> setDefaultAddress(int addressId) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.put(
        Uri.parse('${ApiConstants.baseUrl}/addresses/$addressId/default'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _responseMessage(response, 'Failed to set default address'),
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The server returned an invalid response.');
    }
    return decoded;
  }

  String _responseMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } on FormatException {
      // Use the fallback when the server response is not JSON.
    }
    return fallback;
  }
}
