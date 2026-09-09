import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // The Web application OAuth client ID from Google Cloud Console — the
  // same one your backend checks via GOOGLE_CLIENT_ID. Using this as
  // serverClientId (not the Android/iOS client IDs) is what makes the ID
  // token's audience match on both platforms.
  static const _serverClientId = '789800109263-8vgd1hr1b7q7tccn0jfq760tt8dm5qeh.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _isInitialized = true;
  }

  /// Opens the native Google account picker and returns the ID token to
  /// send to the backend. Returns null if the user backed out of the
  /// picker — that's a cancellation, not an error, so callers shouldn't
  /// treat it as a failure. Any other failure (misconfiguration, network,
  /// Play Services issues, etc.) is rethrown so it isn't hidden as a
  /// silent cancellation.
  Future<String?> signIn() async {
    await initialize();

    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final auth = account.authentication;
      if (auth.idToken == null) {
        throw Exception('Google sign-in did not return an ID token');
      }

      return auth.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // user backed out of the picker — not an error
      }
      rethrow; // surface the real problem (misconfig, network, etc.)
    }
  }

  Future<void> signOut() async {
    await initialize();
    await _googleSignIn.signOut();
  }
}
