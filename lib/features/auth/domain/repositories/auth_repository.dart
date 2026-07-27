import 'package:snapconnect/core/models/user_model.dart';

/// Abstract contract for authentication operations.
/// Domain layer — zero imports from Flutter, Supabase, or Dio.
abstract class IAuthRepository {
  /// Authenticates with email/password. Returns user + token map.
  Future<Map<String, dynamic>> login(String email, String password);

  /// Registers a new user account.
  Future<bool> register(Map<String, dynamic> data);

  /// Exchanges a Google ID token for an app session. Returns user + token map.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken);

  /// Emails a one-time reset code. Resolves even for unregistered addresses,
  /// mirroring the backend's deliberate anti-enumeration behavior.
  Future<void> requestPasswordReset(String email);

  /// Checks a reset code without consuming it.
  Future<void> verifyResetOtp({required String email, required String otp});

  /// Sets a new password using a valid reset code.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  });

  /// Checks the current session by fetching the authenticated user.
  Future<UserModel?> whoAmI();

  /// Clears persisted authentication credentials.
  Future<void> logout();
}
