import 'package:go_router/go_router.dart';
import 'package:snapconnect/features/guest/presentation/screens/event_album_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/guest_landing_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/my_photos_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/photo_picker_screen.dart';
import 'package:snapconnect/features/guest/presentation/screens/upload_success_screen.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/route_transitions.dart';

/// Guest-facing routes that never require authentication — reachable by
/// anyone who scans an event's join code / QR.
final List<RouteBase> guestRoutes = [
  GoRoute(
    path: RoutePaths.guestLanding,
    pageBuilder: (context, state) {
      final joinCode = state.pathParameters['joinCode'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: GuestLandingScreen(joinCode: joinCode),
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.guestAlbum,
        pageBuilder: (context, state) {
          final joinCode = state.pathParameters['joinCode'] ?? '';
          return buildFadeTransitionPage(
            state: state,
            child: EventAlbumScreen(joinCode: joinCode),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.guestPick,
        pageBuilder: (context, state) {
          final joinCode = state.pathParameters['joinCode'] ?? '';
          return buildFadeTransitionPage(
            state: state,
            child: PhotoPickerScreen(joinCode: joinCode),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.guestMyPhotos,
        pageBuilder: (context, state) {
          final joinCode = state.pathParameters['joinCode'] ?? '';
          return buildFadeTransitionPage(
            state: state,
            child: MyPhotosScreen(joinCode: joinCode),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: RoutePaths.uploadSuccess,
    pageBuilder: (context, state) {
      final count =
          int.tryParse(state.uri.queryParameters['count'] ?? '0') ?? 0;
      final joinCode = state.uri.queryParameters['joinCode'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: UploadSuccessScreen(photoCount: count, joinCode: joinCode),
      );
    },
  ),
];
