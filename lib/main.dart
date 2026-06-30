import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:snapconnect/app.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Bootstraps environment variables, DI container, local session,
/// and Supabase before launch.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _safeInitialize();
    Bloc.observer = TalkerBlocObserver(
      talker: sl<Talker>(),
      settings: const TalkerBlocLoggerSettings(
        printEventFullData: false,
        printStateFullData: false,
      ),
    );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SessionCubit>()),
        BlocProvider(create: (_) => sl<ThemeModeCubit>()),
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuth()),
      ],
      child: const SnapConnectApp(),
    ),
  );
}

/// Keeps app startup resilient by swallowing recoverable init failures.
Future<void> _safeInitialize() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Intentionally ignored so the app can still start in local dev.
  }

  await SessionService.instance.init();
  await initDependencies();

  sl<AppLogger>().info('SnapConnect App initialized and starting...');

  // Supabase has been removed
}
