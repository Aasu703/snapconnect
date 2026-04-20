import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/app.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

/// Bootstraps environment variables, local session, and Supabase before launch.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _safeInitialize();
  runApp(const ProviderScope(child: SnapConnectApp()));
}

/// Keeps app startup resilient by swallowing recoverable init failures.
Future<void> _safeInitialize() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Intentionally ignored so the app can still start in local dev.
  }

  await SessionService.instance.init();

  try {
    await SupabaseService.initialize();
  } catch (_) {
    // Supabase initialization can fail in preview environments.
  }
}
