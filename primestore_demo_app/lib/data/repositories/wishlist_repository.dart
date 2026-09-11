import 'dart:convert';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants/api_constants.dart';


class WishlistRepository {
  Future<Map<String, String>> _authHeaders() async {
    final accessToken = await SecureStorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<void> addToWishlist(int productId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/wishlist');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Could not add to wishlist');
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/$productId');
    final response = await http.delete(url, headers: await _authHeaders());

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Could not remove from wishlist');
    }
  }

  Future<List<ProductModel>> fetchWishlist() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/wishlist');
    final response = await http.get(url, headers: await _authHeaders());

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Could not fetch wishlist');
    }

    final data = jsonDecode(response.body);
    final products = data['products'] as List;
    return products.map((p) => ProductModel.fromJson(p)).toList();
  }

  Future<Set<int>> fetchWishlistedIds() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/wishlist/ids');
    final response = await http.get(url, headers: await _authHeaders());

    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    final ids = data['product_ids'] as List;
    return ids.map((id) => id as int).toSet();
  }
}
