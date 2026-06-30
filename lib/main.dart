import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/app.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Bootstraps environment variables, DI container, local session,
/// and Supabase before launch.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _safeInitialize();

  runApp(
    ProviderScope(
      overrides: [
        // TODO: Implement actual overrides if necessary
      ],
      observers: [
        TalkerRiverpodObserver(
          talker: sl<Talker>(),
          settings: const TalkerRiverpodLoggerSettings(),
        ),
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

  // Supabase has been removed
}
