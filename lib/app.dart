import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/constants/app_text_styles.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/providers/session_provider.dart';
import 'package:snapconnect/core/providers/upload_provider.dart';
import 'package:snapconnect/features/albums/album_detail_screen.dart';
import 'package:snapconnect/features/albums/albums_screen.dart';
import 'package:snapconnect/features/albums/create_album_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/create_event_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/event_qr_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/host_album_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/host_dashboard_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/event_album_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/guest_landing_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/my_photos_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/photo_picker_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/upload_success_screen.dart';
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
import 'package:snapconnect/widgets/app_navbar.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Root app widget containing router and global themes.
class SnapConnectApp extends ConsumerWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return BlocProvider(
      create: (_) => sl<AuthCubit>()..checkAuth(),
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
    );
  }

  GoRouter _buildRouter(BuildContext context) {
    return GoRouter(
      observers: [TalkerRouteObserver(sl<Talker>())],
      initialLocation: '/splash',
      redirect: (context, state) {
        if (state.matchedLocation == '/splash' ||
            state.matchedLocation == '/onboarding') {
          return null;
        }

        // Guest routes don't require auth
        if (state.matchedLocation.startsWith('/guest/')) {
          return null;
        }

        final authState = context.read<AuthCubit>().state;
        final bool isAuthenticated = authState is Authenticated;
        final bool isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

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
          pageBuilder: (context, state) => _buildFadeTransitionPage(
            state: state,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              _buildFadeTransitionPage(state: state, child: const LoginPage()),
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
        // ── Guest routes (no auth required) ──────────────────────────
        GoRoute(
          path: '/guest/:joinCode',
          pageBuilder: (context, state) {
            final joinCode = state.pathParameters['joinCode'] ?? '';
            return _buildFadeTransitionPage(
              state: state,
              child: GuestLandingScreen(joinCode: joinCode),
            );
          },
          routes: [
            GoRoute(
              path: 'album',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: EventAlbumScreen(joinCode: joinCode),
                );
              },
            ),
            GoRoute(
              path: 'pick',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: PhotoPickerScreen(joinCode: joinCode),
                );
              },
            ),
            GoRoute(
              path: 'my-photos',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: MyPhotosScreen(joinCode: joinCode),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/upload-success',
          pageBuilder: (context, state) {
            final count =
                int.tryParse(state.uri.queryParameters['count'] ?? '0') ?? 0;
            final joinCode = state.uri.queryParameters['joinCode'] ?? '';
            return _buildFadeTransitionPage(
              state: state,
              child: UploadSuccessScreen(photoCount: count, joinCode: joinCode),
            );
          },
        ),
        // ── Authenticated shell routes ───────────────────────────────
        ShellRoute(
          builder: (context, state, child) {
            return _ShellScaffold(
              location: state.matchedLocation,
              child: child,
            );
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
            // ── Events ───────────────────────────────────────────────
            GoRoute(
              path: '/events',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const HostDashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/events/create',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                state: state,
                child: const CreateEventScreen(),
              ),
            ),
            GoRoute(
              path: '/events/:joinCode/qr',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: EventQRScreen(joinCode: joinCode),
                );
              },
            ),
            GoRoute(
              path: '/events/:joinCode/album',
              pageBuilder: (context, state) {
                final joinCode = state.pathParameters['joinCode'] ?? '';
                return _buildFadeTransitionPage(
                  state: state,
                  child: HostAlbumScreen(joinCode: joinCode),
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
    if (route.startsWith('/events')) {
      return 1;
    }
    if (route.startsWith('/party')) {
      return 2;
    }
    if (route.startsWith('/upload')) {
      return 3;
    }
    if (route.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/events';
      case 2:
        return '/party';
      case 4:
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
          if (selectedIndex == 3) {
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
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onError,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
    textTheme: AppTextStyles.lightTextTheme(),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0, // Handled via ambient shadow in widgets
      color: AppColors.surfaceContainerLowest, // Pure white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 12px standard radius
        side: const BorderSide(color: AppColors.outlineVariant, width: 1), // 1px Light Grey
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest, // White input
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2), // Indigo
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary, // Dark Navy
        foregroundColor: AppColors.onPrimary, // White text
        minimumSize: const Size.fromHeight(52), // Tighter but still large
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface, // Dark text
        backgroundColor: AppColors.surfaceContainerHighest, // Light Grey bg per instructions
        minimumSize: const Size.fromHeight(52),
        side: BorderSide.none, // Secondary buttons use background, not just outline
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      onPrimary: AppColors.onPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ),
    textTheme: AppTextStyles.darkTextTheme(),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
