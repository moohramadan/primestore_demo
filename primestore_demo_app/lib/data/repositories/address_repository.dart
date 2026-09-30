import 'dart:convert';

import 'package:demo_project/features/personalization/models/address_model.dart';
import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AddressController {
  Future<AddressModel> createAddress({
    required String accessToken,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/addresses');
    final response = await http.post(
      url,
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
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AddressModel.fromJson(data['address']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Adding address failed');
    }
  }

  Future<List<AddressModel>> getAddresses(String accessToken) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/addresses');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> addresses = data['addresses'];
      return addresses.map((a) => AddressModel.fromJson(a)).toList();
    } else {
      throw Exception('Failed to load addresses');
    }
  }

}



