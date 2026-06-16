import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// Manages authentication state using injected domain use cases.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial());

  /// Checks existing session on app startup.
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _checkAuthUseCase();
      if (user != null) {
        await SessionService.instance.saveUser(user);
        emit(Authenticated(user: user));
      } else {
        await SessionService.instance.clearUser();
        emit(Unauthenticated());
      }
    } catch (e) {
      await SessionService.instance.clearUser();
      emit(Unauthenticated());
    }
  }

  /// Authenticates with email and password.
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _loginUseCase(email, password);
      final user = result['user'];
      await SessionService.instance.saveUser(user);
      emit(Authenticated(user: user, token: result['token']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Registers a new account.
  Future<void> register(Map<String, dynamic> data) async {
    emit(AuthLoading());
    try {
      final success = await _registerUseCase(data);
      if (success) {
        emit(RegisterSuccess());
      } else {
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Signs out and clears session.
  Future<void> logout() async {
    emit(AuthLoading());
    await _logoutUseCase();
    await SessionService.instance.clearUser();
    emit(Unauthenticated());
  }
}
