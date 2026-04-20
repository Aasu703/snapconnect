import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Supabase initialization and exposes a shared client instance.
final class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  /// Initializes Supabase with environment values when available.
  static Future<void> initialize() async {
    if (_initialized || !AppConstants.hasSupabaseConfig) {
      return;
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    _initialized = true;
  }

  /// Returns whether Supabase is already initialized.
  static bool get isInitialized => _initialized;

  /// Returns the initialized Supabase client.
  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase is not initialized. Check your .env values.');
    }
    return Supabase.instance.client;
  }

  /// Returns the client if available, or null when uninitialized.
  static SupabaseClient? get maybeClient => _initialized ? Supabase.instance.client : null;
}

/// Shortcut getter used by repositories and controllers.
SupabaseClient get supabaseClient => SupabaseService.client;
