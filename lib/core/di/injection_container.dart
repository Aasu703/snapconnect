import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:snapconnect/features/auth/data/repositories/auth_repository.dart';
import 'package:snapconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:snapconnect/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:snapconnect/features/auth/domain/usecases/register_usecase.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Registers all dependencies in the service locator.
///
/// Call this once in [main] before [runApp].
Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ─── Auth Feature ─────────────────────────────────────────────────────────

  // Data layer
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(dio: sl<Dio>(), storage: sl<FlutterSecureStorage>()),
  );

  // Domain layer — use cases
  sl.registerLazySingleton(() => LoginUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<IAuthRepository>()));

  // Presentation layer — BloC / Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      checkAuthUseCase: sl<CheckAuthUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );
}
