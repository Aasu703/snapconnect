import 'package:go_router/go_router.dart';
import 'package:snapconnect/features/legal/screens/privacy_policy_screen.dart';
import 'package:snapconnect/features/legal/screens/terms_of_service_screen.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/route_transitions.dart';

/// Terms of Service / Privacy Policy — reachable both pre-auth (from the
/// sign-up notice) and post-auth (from Profile), so they live outside the
/// authenticated shell and are exempted from the auth redirect.
final List<RouteBase> legalRoutes = [
  GoRoute(
    path: RoutePaths.termsOfService,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const TermsOfServiceScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.privacyPolicy,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const PrivacyPolicyScreen(),
    ),
  ),
];
