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
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/logger/talker_logger.dart';
import 'package:snapconnect/features/albums/albums_controller.dart';
import 'package:snapconnect/features/onboarding/onboarding_controller.dart';
import 'package:snapconnect/features/party/party_controller.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';

import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/blocs/upload_bloc.dart';
import 'package:snapconnect/core/blocs/profile_bloc.dart';
import 'package:snapconnect/core/blocs/reactions_cubit.dart';
import 'package:snapconnect/core/blocs/party_bloc.dart';
import 'package:snapconnect/core/blocs/albums_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Registers all dependencies in the service locator.
///
/// Call this once in [main] before [runApp].
Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Talker>(() => TalkerFlutter.init());
  sl.registerLazySingleton<AppLogger>(() => TalkerLoggerImpl(sl<Talker>()));

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(
      TalkerDioLogger(
        talker: sl<Talker>(),
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );
    return dio;
  });
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

  // ─── Controllers ────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingController>(() => OnboardingController());
  sl.registerLazySingleton<AlbumsController>(() => AlbumsController());
  sl.registerLazySingleton<PhotosController>(() => PhotosController());
  sl.registerLazySingleton<PartyController>(() => PartyController());
  sl.registerLazySingleton<ProfileController>(() => ProfileController());

  // ─── BLoCs / Cubits ─────────────────────────────────────────────────────
  // Global singletons for app-wide state
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit());
  sl.registerLazySingleton<ThemeModeCubit>(() => ThemeModeCubit());
  
  sl.registerFactory<UploadBloc>(() => UploadBloc(sl<PhotosController>()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ProfileController>()));
  sl.registerFactory<PartyBloc>(() => PartyBloc(sl<PartyController>()));
  sl.registerFactory<AlbumsBloc>(() => AlbumsBloc(sl<AlbumsController>()));
}
