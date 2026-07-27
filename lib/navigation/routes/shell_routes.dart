import 'package:go_router/go_router.dart';
import 'package:snapconnect/features/albums/album_detail_screen.dart';
import 'package:snapconnect/features/albums/albums_screen.dart';
import 'package:snapconnect/features/albums/create_album_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/create_event_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/event_qr_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/host_album_screen.dart';
import 'package:snapconnect/features/events/presentation/screens/host_dashboard_screen.dart';
import 'package:snapconnect/features/party/create_party_screen.dart';
import 'package:snapconnect/features/party/join_party_screen.dart';
import 'package:snapconnect/features/party/parties_screen.dart';
import 'package:snapconnect/features/party/party_detail_screen.dart';
import 'package:snapconnect/features/photos/photo_viewer_screen.dart';
import 'package:snapconnect/features/photos/upload_screen.dart';
import 'package:snapconnect/features/profile/profile_screen.dart';
import 'package:snapconnect/navigation/route_paths.dart';
import 'package:snapconnect/navigation/route_transitions.dart';

/// Routes rendered inside the authenticated [AppShellScaffold]
/// (bottom-nav tabs + everything they push to).
final List<RouteBase> shellRoutes = [
  GoRoute(
    path: RoutePaths.home,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const AlbumsScreen()),
  ),
  GoRoute(
    path: RoutePaths.albumCreate,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const CreateAlbumScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.albumDetail,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: AlbumDetailScreen(albumId: id),
      );
    },
  ),
  GoRoute(
    path: RoutePaths.upload,
    pageBuilder: (context, state) {
      return buildFadeTransitionPage(
        state: state,
        child: UploadScreen(
          initialAlbumId: state.uri.queryParameters['albumId'],
        ),
      );
    },
  ),
  // ── Events ─────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.events,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const HostDashboardScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.eventsCreate,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const CreateEventScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.eventQr,
    pageBuilder: (context, state) {
      final joinCode = state.pathParameters['joinCode'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: EventQRScreen(joinCode: joinCode),
      );
    },
  ),
  GoRoute(
    path: RoutePaths.eventAlbum,
    pageBuilder: (context, state) {
      final joinCode = state.pathParameters['joinCode'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: HostAlbumScreen(joinCode: joinCode),
      );
    },
  ),
  // ── Parties ────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.party,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const PartiesScreen()),
  ),
  GoRoute(
    path: RoutePaths.partyCreate,
    pageBuilder: (context, state) => buildFadeTransitionPage(
      state: state,
      child: const CreatePartyScreen(),
    ),
  ),
  GoRoute(
    path: RoutePaths.partyDetail,
    pageBuilder: (context, state) {
      final joinCode = state.pathParameters['joinCode'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: PartyDetailScreen(joinCode: joinCode),
      );
    },
  ),
  GoRoute(
    path: RoutePaths.joinPartyEntry,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const JoinPartyScreen()),
  ),
  GoRoute(
    path: RoutePaths.joinParty,
    pageBuilder: (context, state) {
      return buildFadeTransitionPage(
        state: state,
        child: JoinPartyScreen(joinCode: state.pathParameters['joinCode']),
      );
    },
  ),
  // ── Profile & photos ──────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.profile,
    pageBuilder: (context, state) =>
        buildFadeTransitionPage(state: state, child: const ProfileScreen()),
  ),
  GoRoute(
    path: RoutePaths.photoViewer,
    pageBuilder: (context, state) {
      final photoId = state.pathParameters['id'] ?? '';
      final albumId = state.uri.queryParameters['albumId'] ?? '';
      return buildFadeTransitionPage(
        state: state,
        child: PhotoViewerScreen(photoId: photoId, albumId: albumId),
      );
    },
  ),
];
