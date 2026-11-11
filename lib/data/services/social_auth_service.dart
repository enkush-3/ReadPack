import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  SocialAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleInitialization;

  static Future<String?> signInWithGoogle() async {
    final serverClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ).trim();
    _googleInitialization ??= _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    await _googleInitialization;

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google did not return an ID token. Check the native OAuth client configuration.',
      );
    }
    return idToken;
  }

  static Future<String?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );
    if (result.status == LoginStatus.cancelled) return null;
    if (result.status != LoginStatus.success) {
      throw StateError(result.message ?? 'Facebook sign-in failed.');
    }

    final accessToken = result.accessToken?.tokenString;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Facebook did not return an access token.');
    }
    return accessToken;
  }
}
