import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_state.dart';
import 'package:snapconnect/navigation/app_shell_scaffold.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/routes/guest_routes.dart';
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
  if (state.matchedLocation == RoutePaths.splash ||
      state.matchedLocation == RoutePaths.onboarding) {
    return null;
  }

  // Guest routes don't require auth.
  if (state.matchedLocation.startsWith('/guest/')) {
    return null;
  }

  final authState = context.read<AuthCubit>().state;
  final bool isAuthenticated = authState is Authenticated;
  final bool isLoggingIn =
      state.matchedLocation == RoutePaths.login ||
      state.matchedLocation == RoutePaths.register;

  if (!isAuthenticated && !isLoggingIn) {
    return RoutePaths.login;
  }

  if (isAuthenticated && isLoggingIn) {
    return RoutePaths.home;
  }

  return null;
}
