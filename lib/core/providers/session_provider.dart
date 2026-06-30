import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/session_service.dart';

class SessionNotifier extends StateNotifier<UserModel?> {
  SessionNotifier() : super(SessionService.instance.getUser());
  // user session state management using Riverpod's StateNotifier. It initializes the state with the current user from the SessionService.
  Future<void> setUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    state = user;
  }

  // update the user session state and persist it using the SessionService.
  Future<void> updateUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    state = user;
  }

  // clear the user session state and persist it using the SessionService.
  Future<void> clear() async {
    await SessionService.instance.clearUser();
    state = null;
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier()
    : super(
        SessionService.instance.isDarkMode() ? ThemeMode.dark : ThemeMode.light,
      );

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await SessionService.instance.setDarkMode(next == ThemeMode.dark);
    state = next;
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, UserModel?>(
  (ref) => SessionNotifier(),
);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
