import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/common/theme/app_theme.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_state.dart';
import 'package:snapconnect/navigation/app_router.dart';

/// Root app widget wiring global theme + the app router together.
/// Routing itself lives in `lib/navigation/` (separation of concerns).
class SnapConnectApp extends StatelessWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // AuthCubit.login()/checkAuth() persist the account to SessionService
      // storage, but SessionCubit — the live singleton every dashboard
      // screen actually watches — only reads that storage once, at app
      // boot. Without this, screens keep showing whatever identity was
      // cached at startup (e.g. a leftover guest identity) until a full
      // restart. Pushing the user into SessionCubit here keeps both in
      // sync the moment auth succeeds, whether via explicit login or the
      // silent checkAuth() on cold start.
      listenWhen: (previous, current) => current is Authenticated,
      listener: (context, state) {
        context.read<SessionCubit>().setUser((state as Authenticated).user);
      },
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
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
      ),
    );
  }
}
