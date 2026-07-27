import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Exchanges a Google ID token for an app session.
class GoogleSignInUseCase {
  final IAuthRepository _repository;

  const GoogleSignInUseCase(this._repository);

  /// Executes the exchange, returning a `{user, token}` map.
  Future<Map<String, dynamic>> call(String idToken) =>
      _repository.loginWithGoogle(idToken);
}