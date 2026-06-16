import 'package:snapconnect/core/models/user_model.dart';

/// Abstract contract for authentication operations.
/// Domain layer — zero imports from Flutter, Supabase, or Dio.
abstract class IAuthRepository {
  /// Authenticates with email/password. Returns user + token map.
  Future<Map<String, dynamic>> login(String email, String password);

  /// Registers a new user account.
  Future<bool> register(Map<String, dynamic> data);

  /// Checks the current session by fetching the authenticated user.
  Future<UserModel?> whoAmI();

  /// Clears persisted authentication credentials.
  Future<void> logout();
}
