import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/common/theme/app_theme.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/navigation/app_router.dart';

/// Root app widget wiring global theme + the app router together.
/// Routing itself lives in `lib/navigation/` (separation of concerns).
class SnapConnectApp extends StatelessWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final router = buildAppRouter(context);
        return MaterialApp.router(
          title: 'SnapConnect',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
        );
      },
    );
  }
}
