import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
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
  final GoogleSignInUseCase _googleSignInUseCase;
  final GoogleAuthService _googleAuthService;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required LogoutUseCase logoutUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GoogleAuthService googleAuthService,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        _logoutUseCase = logoutUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _googleAuthService = googleAuthService,
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

  /// Signs in with Google, exchanging the ID token for an app session.
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final idToken = await _googleAuthService.signIn();
      if (idToken == null) {
        // User dismissed the account picker — not an error, so fall back to
        // the pre-attempt state rather than showing a failure message.
        emit(Unauthenticated());
        return;
      }

      final result = await _googleSignInUseCase(idToken);
      final user = result['user'];
      await SessionService.instance.saveUser(user);
      sl<AppLogger>().good('Google sign-in succeeded for ${user.email}');
      emit(Authenticated(user: user, token: result['token']));
    } catch (e) {
      sl<AppLogger>().error('Google sign-in failed: $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Registers a new account.
  Future<void> register(Map<String, dynamic> data) async {
    emit(AuthLoading());
    try {
      final success = await _registerUseCase(data);
      if (success) {
        sl<AppLogger>().good('User successfully registered: ${data['email'] ?? data['fullName'] ?? 'Unknown'}');
        emit(RegisterSuccess());
      } else {
        sl<AppLogger>().warning('User registration failed for: ${data['email'] ?? 'Unknown'}');
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      sl<AppLogger>().error('Error during registration: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Signs out and clears session.
  Future<void> logout() async {
    emit(AuthLoading());
    await _logoutUseCase();
    // Without this, the next Google sign-in silently reuses the cached account
    // instead of letting the user pick one.
    await _googleAuthService.signOut();
    await SessionService.instance.clearUser();
    emit(Unauthenticated());
  }
}
