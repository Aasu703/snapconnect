import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapconnect/core/constants/app_constants.dart';

/// Raised when Google sign-in can't proceed for a reason worth showing the
/// user. User cancellation is *not* an error — [GoogleAuthService.signIn]
/// returns null for that instead.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Wraps the `google_sign_in` plugin so the rest of the app only ever deals
/// with an ID token, which the backend exchanges for an app JWT.
///
/// The plugin is a process-wide singleton that must be initialized exactly
/// once before use, so that's handled lazily here.
class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // serverClientId is the *web* OAuth client ID. Android needs it to mint an
    // ID token the backend can verify; without it the token's audience won't
    // match and verification fails.
    if (AppConstants.googleServerClientId.isEmpty) {
      throw const GoogleAuthException(
        'Google sign-in is not configured. Set GOOGLE_SERVER_CLIENT_ID in .env.',
      );
    }

    await _googleSignIn.initialize(
      serverClientId: AppConstants.googleServerClientId,
    );
    _initialized = true;
  }

  /// Prompts for a Google account and returns its ID token, or null if the
  /// user dismissed the picker.
  Future<String?> signIn() async {
    await _ensureInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Google sign-in is not supported on this platform.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google did not return an ID token. Check the OAuth client setup.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw GoogleAuthException(
        e.description ?? 'Google sign-in failed. Please try again.',
      );
    }
  }

  /// Clears the cached Google account so the next sign-in re-prompts.
  Future<void> signOut() async {
    if (!_initialized) return;
    await _googleSignIn.signOut();
  }
}
