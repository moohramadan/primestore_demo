import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthController {
  

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Sign up failed');
    }
  }
  Future<UserModel> login({
  String? email,
  String? phone,
  required String password,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/login');

  final body = <String, dynamic>{'password': password};
  if (email != null) body['email'] = email;
  if (phone != null) body['phone'] = phone;

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    return UserModel.fromJson(jsonDecode(response.body));
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Login failed');
  }
}
}
