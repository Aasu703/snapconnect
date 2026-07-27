import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';

/// Sends a one-time reset code to the given email.
class RequestPasswordResetUseCase {
  final IAuthRepository _repository;

  const RequestPasswordResetUseCase(this._repository);

  Future<void> call(String email) => _repository.requestPasswordReset(email);
}

/// Checks a reset code without consuming it, so the UI can advance to the
/// new-password step before the user commits.
class VerifyResetOtpUseCase {
  final IAuthRepository _repository;

  const VerifyResetOtpUseCase(this._repository);

  Future<void> call({required String email, required String otp}) =>
      _repository.verifyResetOtp(email: email, otp: otp);
}

/// Sets a new password using a valid reset code.
class ResetPasswordUseCase {
  final IAuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<void> call({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) =>
      _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        confirmPassword: confirmPassword,
      );
}