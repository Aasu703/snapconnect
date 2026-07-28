import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/features/auth/domain/usecases/password_reset_usecases.dart';

/// Which step of the reset wizard the user is on.
enum PasswordResetStep { enterEmail, enterOtp, enterNewPassword, done }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.step = PasswordResetStep.enterEmail,
    this.email = '',
    this.otp = '',
    this.isSubmitting = false,
    this.error,
  });

  final PasswordResetStep step;
  final String email;
  final String otp;
  final bool isSubmitting;
  final String? error;

  static const Object _unset = Object();

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? email,
    String? otp,
    bool? isSubmitting,
    Object? error = _unset,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [step, email, otp, isSubmitting, error];
}

/// Drives the email → OTP → new-password reset flow.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required VerifyResetOtpUseCase verifyResetOtpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _requestPasswordReset = requestPasswordResetUseCase,
        _verifyResetOtp = verifyResetOtpUseCase,
        _resetPassword = resetPasswordUseCase,
        super(const PasswordResetState());

  final RequestPasswordResetUseCase _requestPasswordReset;
  final VerifyResetOtpUseCase _verifyResetOtp;
  final ResetPasswordUseCase _resetPassword;

  /// Requests a code. Advances to the OTP step regardless of whether the
  /// address is registered — the backend intentionally doesn't disclose that,
  /// and neither should this screen.
  Future<void> sendCode(String email) async {
    final trimmed = email.trim();
    emit(state.copyWith(isSubmitting: true, error: null, email: trimmed));

    try {
      await _requestPasswordReset(trimmed);
      emit(state.copyWith(
        isSubmitting: false,
        step: PasswordResetStep.enterOtp,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _message(e)));
    }
  }

  Future<void> verifyCode(String otp) async {
    final trimmed = otp.trim();
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      await _verifyResetOtp(email: state.email, otp: trimmed);
      emit(state.copyWith(
        isSubmitting: false,
        otp: trimmed,
        step: PasswordResetStep.enterNewPassword,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _message(e)));
    }
  }

  Future<void> submitNewPassword({
    required String password,
    required String confirmPassword,
  }) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      await _resetPassword(
        email: state.email,
        otp: state.otp,
        password: password,
        confirmPassword: confirmPassword,
      );
      emit(state.copyWith(
        isSubmitting: false,
        step: PasswordResetStep.done,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _message(e)));
    }
  }

  /// Returns to the email step so the user can correct a typo'd address.
  void restart() => emit(const PasswordResetState());

  void clearError() => emit(state.copyWith(error: null));

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
