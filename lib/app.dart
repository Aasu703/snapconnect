import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/constants/app_text_styles.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/features/albums/album_detail_screen.dart';
import 'package:snapconnect/features/albums/albums_screen.dart';
import 'package:snapconnect/features/albums/create_album_screen.dart';
import 'package:snapconnect/features/onboarding/onboarding_screen.dart';
import 'package:snapconnect/features/party/create_party_screen.dart';
import 'package:snapconnect/features/party/join_party_screen.dart';
import 'package:snapconnect/features/party/parties_screen.dart';
import 'package:snapconnect/features/party/party_detail_screen.dart';
import 'package:snapconnect/features/photos/photo_viewer_screen.dart';
import 'package:snapconnect/features/photos/upload_screen.dart';
import 'package:snapconnect/features/profile/profile_screen.dart';
import 'package:snapconnect/features/splash/splash_screen.dart';
import 'package:snapconnect/widgets/app_navbar.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/constants/app_text_styles.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/features/albums/album_detail_screen.dart';
import 'package:snapconnect/features/albums/albums_screen.dart';
import 'package:snapconnect/features/albums/create_album_screen.dart';
import 'package:snapconnect/features/onboarding/onboarding_screen.dart';
import 'package:snapconnect/features/party/create_party_screen.dart';
import 'package:snapconnect/features/party/join_party_screen.dart';
import 'package:snapconnect/features/party/parties_screen.dart';
import 'package:snapconnect/features/party/party_detail_screen.dart';
import 'package:snapconnect/features/photos/photo_viewer_screen.dart';
import 'package:snapconnect/features/photos/upload_screen.dart';
import 'package:snapconnect/features/profile/profile_screen.dart';
import 'package:snapconnect/features/splash/splash_screen.dart';
import 'package:snapconnect/features/auth/presentation/pages/login_page.dart';
import 'package:snapconnect/features/auth/presentation/pages/register_page.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_cubit.dart';
import 'package:snapconnect/features/auth/presentation/BloC/auth_state.dart';
import 'package:snapconnect/features/auth/data/repositories/auth_repository.dart';
import 'package:snapconnect/widgets/app_navbar.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Root app widget containing router and global themes.
class SnapConnectApp extends ConsumerWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>())..checkAuth(),
        child: Builder(
          builder: (context) {
            final router = _buildRouter(context);
            return MaterialApp.router(
              title: 'SnapConnect',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }

  GoRouter _buildRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        if (state.matchedLocation == '/splash') {
          return null;
        }

        final authState = context.read<AuthCubit>().state;
        final bool isAuthenticated = authState is Authenticated;
        final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              _buildFadeTransitionPage(state: state, child: const SplashScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            state: state,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            state: state,
            child: const RegisterPage(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            state: state,
            child: const OnboardingScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return _ShellScaffold(location: state.matchedLocation, child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const AlbumsScreen(),
              ),
            ),
            GoRoute(
              path: '/album/create',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const CreateAlbumScreen(),
              ),
            ),
            GoRoute(
              path: '/album/:id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: AlbumDetailScreen(albumId: id),
                );
              },
            ),
            GoRoute(
              path: '/upload',
              pageBuilder: (context, state) {
                return _buildFadeTransitionPage(
                  state: state,
                  child: UploadScreen(
                    initialAlbumId: state.uri.queryParameters['albumId'],
                  ),
                );
              },
            ),
            GoRoute(
              path: '/party',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const PartiesScreen(),
              ),
            ),
            GoRoute(
              path: '/party/create',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const CreatePartyScreen(),
              ),
            ),
            GoRoute(
              path: '/party/:joinCode',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: PartyDetailScreen(joinCode: joinCode),
                );
              },
            ),
            GoRoute(
              path: '/join/:joinCode',
              pageBuilder: (context, state) {
                return _buildFadeTransitionPage(
                  state: state,
                  child: JoinPartyScreen(
                    joinCode: state.pathParameters['joinCode'],
                  ),
                );
              },
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const ProfileScreen(),
              ),
            ),
            GoRoute(
              path: '/photo/:id',
              pageBuilder: (context, state) {
                final photoId = state.pathParameters['id'] ?? '';
                final albumId = state.uri.queryParameters['albumId'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: PhotoViewerScreen(photoId: photoId, albumId: albumId),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

CustomTransitionPage<void> _buildFadeTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    // Laws of UX: Doherty Threshold keeps route transitions below 300ms.
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.02, 0.02),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.location, required this.child});

  final String location;
  final Widget child;

  int _currentIndex(String route) {
    if (route.startsWith('/party')) {
      return 1;
    }
    if (route.startsWith('/upload')) {
      return 2;
    }
    if (route.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/party';
      case 3:
        return '/profile';
      default:
        return '/';
    }
  }

  Future<void> _openUpload(BuildContext context, WidgetRef ref) async {
    if (location.startsWith('/upload')) {
      return;
    }

    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Before uploading',
        subtitle: 'Set your identity before uploading photos.',
      );
    }

    if (!context.mounted || ref.read(sessionProvider) == null) {
      return;
    }

    context.push('/upload');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(location);
    final uploadState = ref.watch(uploadProvider);
    final progress = uploadState.totalCount == 0
        ? 0.0
        : uploadState.uploadedCount / uploadState.totalCount;

    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavbar(
        currentIndex: index,
        uploadInProgress: uploadState.isUploading,
        uploadProgress: progress,
        onTap: (selectedIndex) {
          if (selectedIndex == 2) {
            _openUpload(context, ref);
            return;
          }

          final route = _routeForIndex(selectedIndex);
          if (location == route) {
            return;
          }

          context.go(route);
        },
      ),
    );
  }
}

ThemeData _lightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    textTheme: AppTextStyles.lightTextTheme(),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F3F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
      ),
    ),
  );
}

ThemeData _darkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      surface: AppColors.darkSurface,
    ),
    textTheme: AppTextStyles.darkTextTheme(),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
