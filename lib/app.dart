import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/common/theme/app_theme.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/utils/party_invite_link.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_state.dart';
import 'package:snapconnect/navigation/app_router.dart';
import 'package:snapconnect/navigation/route_paths.dart';

/// Root app widget wiring global theme, deep links, and the app router.
/// Routing itself lives in `lib/navigation/` (separation of concerns).
class SnapConnectApp extends StatefulWidget {
  const SnapConnectApp({super.key});

  @override
  State<SnapConnectApp> createState() => _SnapConnectAppState();
}

class _SnapConnectAppState extends State<SnapConnectApp> {
  // Built once and held for the app's lifetime: rebuilding the router (e.g.
  // on a theme change) would throw away navigation history.
  late final GoRouter _router;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(context);
    _appLinks = AppLinks();
    _listenForDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Routes `snapconnect://join/<CODE>` invites, whether the link cold-started
  /// the app or arrived while it was already running.
  void _listenForDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {},
    );
  }

  void _handleDeepLink(Uri uri) {
    final joinCode = PartyInviteLink.parseJoinCode(uri.toString());
    if (joinCode == null) return;

    _router.go(RoutePaths.joinPartyFor(joinCode));
  }

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
          return MaterialApp.router(
            title: 'SnapConnect',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
