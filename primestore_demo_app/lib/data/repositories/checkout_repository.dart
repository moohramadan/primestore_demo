import 'dart:convert';

import 'package:demo_project/data/repositories/authenticated_http_client.dart';
import 'package:demo_project/features/shop/models/order_model.dart';
import 'package:demo_project/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class CheckoutRepository {
  final AuthenticatedHttpClient _authenticatedClient =
      AuthenticatedHttpClient();

  Future<OrderModel> placeOrder({
    required int addressId,
    required String idempotencyKey,
  }) async {
    final response = await _authenticatedClient.send(
      (accessToken) => http.post(
        Uri.parse('${ApiConstants.baseUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Idempotency-Key': idempotencyKey,
        },
        body: jsonEncode({'address_id': addressId}),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_responseMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The server returned an invalid order.');
    }
    return OrderModel.fromJson(decoded);
  }

  String _responseMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['error'] is String) {
        final message = decoded['error'] as String;
        if (decoded['variant_id'] is num) {
          return '$message (variant ${(decoded['variant_id'] as num).toInt()})';
        }
        return message;
      }
    } on FormatException {
      // Use the status fallback when the server response is not JSON.
    }
    return 'Could not place your order (${response.statusCode})';
  }
}
