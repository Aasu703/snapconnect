import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use case for checking authentication status.
class CheckAuthUseCase {
  final IAuthRepository _repository;

  const CheckAuthUseCase(this._repository);

  /// Returns the current authenticated user, or null if unauthenticated.
  Future<UserModel?> call() {
    return _repository.whoAmI();
  }
}
