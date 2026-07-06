import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use case for logging out.
class LogoutUseCase {
  final IAuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// Clears all authentication credentials and session data.
  Future<void> call() {
    return _repository.logout();
  }
}
