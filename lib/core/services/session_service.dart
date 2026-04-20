import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapconnect/core/models/user_model.dart';

/// Local persistence for user identity and app preferences.
final class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  static const String _userKey = 'sc_user';
  static const String _darkModeKey = 'sc_dark_mode';
  static const String _onboardingCompletedKey = 'sc_onboarding_completed';

  SharedPreferences? _prefs;

  /// Initializes shared preferences.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Persists user identity payload.
  Future<void> saveUser(UserModel user) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
    await setOnboardingCompleted(true);
  }

  /// Restores user identity payload.
  UserModel? getUser() {
    final raw = _prefs?.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clears user identity while preserving app preferences.
  Future<void> clearUser() async {
    await init();
    await _prefs!.remove(_userKey);
  }

  /// Returns whether a session exists.
  bool isLoggedIn() {
    return getUser() != null;
  }

  /// Persists dark mode preference.
  Future<void> setDarkMode(bool enabled) async {
    await init();
    await _prefs!.setBool(_darkModeKey, enabled);
  }

  /// Returns persisted dark mode preference.
  bool isDarkMode() {
    return _prefs?.getBool(_darkModeKey) ?? false;
  }

  /// Persists onboarding completion state.
  Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _prefs!.setBool(_onboardingCompletedKey, completed);
  }

  /// Returns whether onboarding has been completed at least once.
  bool isOnboardingCompleted() {
    return _prefs?.getBool(_onboardingCompletedKey) ?? false;
  }
}
