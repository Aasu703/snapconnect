import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use case for user registration.
class RegisterUseCase {
  final IAuthRepository _repository;

  const RegisterUseCase(this._repository);

  /// Executes registration with the provided user data.
  Future<bool> call(Map<String, dynamic> data) {
    return _repository.register(data);
  }
}
