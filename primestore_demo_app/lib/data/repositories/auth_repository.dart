import 'dart:convert';
import 'package:demo_project/features/autentication/models/user_model.dart';
import 'package:demo_project/features/shop/models/product_model.dart';
import 'package:http/http.dart' as http;
import '../../../utils/constants/api_constants.dart';

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  LoginResult({required this.accessToken, required this.refreshToken, required this.user});
}
  
class UnverifiedEmailException implements Exception {
  final String email;
  UnverifiedEmailException(this.email);
}
class RefreshResult {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  RefreshResult({required this.accessToken, required this.refreshToken, required this.user});
}

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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Sign up failed');
    }
  } // keep as-is

  Future<LoginResult> login({
  String? email,
  String? phone,
  required String password,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/login');

  final body = <String, dynamic>{'password': password};
  if (email != null) body['email'] = email;
  if (phone != null) body['phone'] = phone;

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return LoginResult(
    accessToken: data['access_token'],
    refreshToken: data['refresh_token'],
    user: UserModel.fromJson(data['user']),
  );
}
else if (response.statusCode == 403) {
    throw UnverifiedEmailException(email ?? '');
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Login failed');
  }
}


Future<LoginResult> googleSignIn(String idToken) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/google-signin');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id_token': idToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return LoginResult(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      user: UserModel.fromJson(data['user']),
    );
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Google sign-in failed');
  }
}

Future<String> sendOtp(String email) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/verify-email/send');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['otp_token'];
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to send code');
  }
}

Future<String>requestEmailChange(String accessToken, String newEmail)async{
  final url = Uri.parse('${ApiConstants.baseUrl}/users/me/email/request');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    body: jsonEncode({'new_email' : newEmail}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['otp_token'];
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to send code');
  }
}
Future<UserModel> confirmEmailChange(String otpToken, String otp, String accessToken) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/me/email/confirm');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    body: jsonEncode({'otp_token': otpToken, 'otp': otp}),
  );

   if (response.statusCode == 200) {
    return UserModel.fromJson(jsonDecode(response.body));
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to load profile');
  }
}

Future<void> confirmOtp(String otpToken, String otp) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/verify-email/confirm');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'otp_token': otpToken, 'otp': otp}),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Invalid or expired code');
  }
}


Future<RefreshResult> refreshSession(String refreshToken) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/refresh');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh_token': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return RefreshResult(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      user: UserModel.fromJson(data['user']),
    );
  } else {
    throw Exception('Session expired');
  }
}
Future<void> logout(String refreshToken) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/logout');
  try {
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
  } catch (_) {
    // ignore network errors — logging out locally should still succeed
  }
}
Future<UserModel> getMe(String accessToken) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/me');

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode == 200) {
    return UserModel.fromJson(jsonDecode(response.body));
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to load profile');
  }
}
Future<List<ProductModel>> getFeaturedProducts() async {
  final url = Uri.parse('${ApiConstants.baseUrl}/products/featured');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((p) => ProductModel.fromJson(p)).toList();
  } else {
    throw Exception('Failed to load featured products');
  }
}



}
