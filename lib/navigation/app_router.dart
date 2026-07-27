import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_state.dart';
import 'package:snapconnect/navigation/app_shell_scaffold.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/routes/guest_routes.dart';
import 'package:snapconnect/navigation/routes/legal_routes.dart';
import 'package:snapconnect/navigation/routes/public_routes.dart';
import 'package:snapconnect/navigation/routes/shell_routes.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Builds the app's [GoRouter], composing the public, guest, and
/// authenticated-shell route groups and enforcing the auth redirect.
GoRouter buildAppRouter(BuildContext context) {
  return GoRouter(
    observers: [TalkerRouteObserver(sl<Talker>())],
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => _redirect(context, state),
    routes: [
      ...publicRoutes,
      ...guestRoutes,
      ...legalRoutes,
      ShellRoute(
        builder: (context, state, child) {
          return AppShellScaffold(location: state.matchedLocation, child: child);
        },
        routes: shellRoutes,
      ),
    ],
  );
}

String? _redirect(BuildContext context, GoRouterState state) {
  if (state.matchedLocation == RoutePaths.splash) {
    return null;
  }

  // Guest routes don't require auth.
  if (state.matchedLocation.startsWith('/guest/')) {
    return null;
  }

  // Terms of Service / Privacy Policy are reachable pre- and post-auth.
  if (state.matchedLocation.startsWith('/legal/')) {
    return null;
  }

  final authState = context.read<AuthCubit>().state;
  final bool isAuthenticated = authState is Authenticated;
  final bool isLoggingIn =
      state.matchedLocation == RoutePaths.login ||
      state.matchedLocation == RoutePaths.register;

  // A join deep link (snapconnect://join/<code>) can arrive while logged out —
  // typically a guest scanning a host's QR. Hand them to the guest flow with
  // the code intact instead of bouncing to /login, which would drop it.
  if (!isAuthenticated && state.matchedLocation.startsWith('/join/')) {
    final joinCode = state.pathParameters['joinCode'];
    if (joinCode != null && joinCode.isNotEmpty) {
      return RoutePaths.guestLandingFor(joinCode);
    }
  }

  if (!isAuthenticated && !isLoggingIn) {
    return RoutePaths.login;
  }

  if (isAuthenticated && isLoggingIn) {
    return RoutePaths.home;
  }

  return null;
}
