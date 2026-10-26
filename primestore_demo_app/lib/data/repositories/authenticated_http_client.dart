import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthenticatedHttpClient {
  static Future<String>? _refreshFuture;

  Future<http.Response> send(
    Future<http.Response> Function(String accessToken) request,
  ) async {
    final storedToken = await SecureStorageService.getAccessToken();
    final token = storedToken == null || storedToken.isEmpty
        ? await _refreshAccessToken()
        : storedToken;
    final response = await request(token);
    if (response.statusCode != 401) return response;

    final latestToken = await SecureStorageService.getAccessToken();
    if (latestToken != null && latestToken.isNotEmpty && latestToken != token) {
      return request(latestToken);
    }
    return request(await _refreshAccessToken());
  }

  Future<String> _refreshAccessToken() async {
    final currentRefresh = _refreshFuture;
    if (currentRefresh != null) return currentRefresh;

    final future = _performRefresh();
    _refreshFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshFuture, future)) _refreshFuture = null;
    }
  }

  Future<String> _performRefresh() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('Please sign in again to continue.');
      }

      final session = await AuthController().refreshSession(refreshToken);
      await SecureStorageService.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().setSession(
          session.user,
          session.accessToken,
        );
      }
      return session.accessToken;
    } on SessionExpiredException {
      await SecureStorageService.clearTokens();
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().clearSession();
      }
      rethrow;
    }
  }
}
