import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use case for user login.
class LoginUseCase {
  final IAuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Executes login with the given credentials.
  Future<Map<String, dynamic>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
