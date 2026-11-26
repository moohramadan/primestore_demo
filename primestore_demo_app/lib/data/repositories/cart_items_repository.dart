import 'dart:convert';

import 'package:demo_project/features/shop/models/cart_model.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants/api_constants.dart';

import 'dart:convert';

import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants/api_constants.dart';

class CartItemsRepository {
  Future<Map<String, String>> _authHeaders() async {
    final accessToken = await SecureStorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Throws if the response is not 200, using the server's message when it
  /// sent one and [fallback] when the body is not the JSON we expect.
  void _ensureSuccess(http.Response response, String fallback) {
    if (response.statusCode == 200) return;
    var message = fallback;
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is String) {
        message = body['error'] as String;
      }
    } catch (_) {
      // body was not JSON, keep the fallback message
    }
    throw Exception(message);
  }

  Future<void> addCartItem({
    required int productVariantId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart/items'),
      headers: await _authHeaders(),
      body: jsonEncode({'variant_id': productVariantId, 'quantity': quantity}),
    );
    _ensureSuccess(response, 'Could not add item to cart');
  }

  Future<void> setCartItemQuantity({
    required int productVariantId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/cart/items/$productVariantId'),
      headers: await _authHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );
    _ensureSuccess(response, 'Could not update quantity');
  }

  Future<void> removeCartItem(int productVariantId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart/items/$productVariantId'),
      headers: await _authHeaders(),
    );
    _ensureSuccess(response, 'Could not remove item');
  }

  Future<CartModel> getCart() async {
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/cart'),
    headers: await _authHeaders(),
  );
  _ensureSuccess(response, 'Could not get cart');

  return CartModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
}