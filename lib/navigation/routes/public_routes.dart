import 'package:go_router/go_router.dart';
import 'package:snapconnect/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:snapconnect/features/auth/presentation/pages/login_page.dart';
import 'package:snapconnect/features/auth/presentation/pages/register_page.dart';
import 'package:snapconnect/features/splash/splash_screen.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/route_transitions.dart';

/// Routes reachable before authentication: splash, login, register (which
/// also hosts the sliding welcome/sign-up wizard).
final List<RouteBase> publicRoutes = [
  GoRoute(
    path: RoutePaths.splash,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const SplashScreen()),
  ),
  GoRoute(
    path: RoutePaths.login,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const LoginPage()),
  ),
  GoRoute(
    path: RoutePaths.register,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const RegisterPage()),
  ),
  GoRoute(
    path: RoutePaths.forgotPassword,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const ForgotPasswordPage(),
    ),
  ),
];
