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
import 'package:snapconnect/widgets/app_navbar.dart';

/// Root app widget containing router and global themes.
class SnapConnectApp extends ConsumerWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SnapConnect',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      routerConfig: router,
    );
  }
}

/// Router provider with onboarding redirect and shell navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = SessionService.instance.isOnboardingCompleted();

  return GoRouter(
    initialLocation: onboardingDone ? '/' : '/onboarding',
    redirect: (context, state) {
      final onboardingComplete = SessionService.instance
          .isOnboardingCompleted();

      if (!onboardingComplete && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      if (onboardingComplete && state.matchedLocation == '/onboarding') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _ShellScaffold(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const AlbumsScreen()),
          GoRoute(
            path: '/album/create',
            builder: (context, state) => const CreateAlbumScreen(),
          ),
          GoRoute(
            path: '/album/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return AlbumDetailScreen(albumId: id);
            },
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              return UploadScreen(
                initialAlbumId: state.uri.queryParameters['albumId'],
              );
            },
          ),
          GoRoute(
            path: '/party',
            builder: (context, state) => const PartiesScreen(),
          ),
          GoRoute(
            path: '/party/create',
            builder: (context, state) => const CreatePartyScreen(),
          ),
          GoRoute(
            path: '/party/:joinCode',
            builder: (context, state) {
              final joinCode = state.pathParameters['joinCode'] ?? '';
              return PartyDetailScreen(joinCode: joinCode);
            },
          ),
          GoRoute(
            path: '/join/:joinCode',
            builder: (context, state) {
              return JoinPartyScreen(
                joinCode: state.pathParameters['joinCode'],
              );
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/photo/:id',
            builder: (context, state) {
              final photoId = state.pathParameters['id'] ?? '';
              final albumId = state.uri.queryParameters['albumId'] ?? '';
              return PhotoViewerScreen(photoId: photoId, albumId: albumId);
            },
          ),
        ],
      ),
    ],
  );
});

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavbar(
        location: location,
        onNavigate: (route) {
          if (route == location) {
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
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
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
