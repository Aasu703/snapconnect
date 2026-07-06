import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';

class SessionCubit extends Cubit<UserModel?> {
  SessionCubit() : super(SessionService.instance.getUser()) {
    sl<AppLogger>().debug('SessionCubit initialized with user: ${state?.id}');
  }

  Future<void> setUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    emit(user);
    sl<AppLogger>().info('User session set: ${user.id}');
  }

  Future<void> updateUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    emit(user);
    sl<AppLogger>().info('User session updated: ${user.id}');
  }

  Future<void> clear() async {
    await SessionService.instance.clearUser();
    emit(null);
    sl<AppLogger>().info('User session cleared');
  }
}

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit()
      : super(SessionService.instance.isDarkMode() ? ThemeMode.dark : ThemeMode.light) {
    sl<AppLogger>().debug('ThemeModeCubit initialized with theme: $state');
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await SessionService.instance.setDarkMode(next == ThemeMode.dark);
    emit(next);
    sl<AppLogger>().info('Theme toggled to: $next');
  }
}
