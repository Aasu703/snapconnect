/// Centralized route path constants.
///
/// Single source of truth for every path string used by [GoRouter] route
/// definitions and by `context.go(...)` / `context.push(...)` call sites,
/// so a path never has to be retyped (and risk a typo) in more than one place.
final class RoutePaths {
  RoutePaths._();

  // --- Public / unauthenticated ---
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // --- Guest (no auth required) ---
  static const String guestLanding = '/guest/:joinCode';
  static const String guestAlbum = 'album';
  static const String guestPick = 'pick';
  static const String guestMyPhotos = 'my-photos';
  static const String uploadSuccess = '/upload-success';

  static String guestLandingFor(String joinCode) => '/guest/$joinCode';
  static String guestAlbumFor(String joinCode) => '/guest/$joinCode/album';
  static String guestPickFor(String joinCode) => '/guest/$joinCode/pick';
  static String guestMyPhotosFor(String joinCode) =>
      '/guest/$joinCode/my-photos';

  // --- Authenticated shell ---
  static const String home = '/';
  static const String albumCreate = '/album/create';
  static const String albumDetail = '/album/:id';
  static const String upload = '/upload';
  static const String events = '/events';
  static const String eventsCreate = '/events/create';
  static const String eventQr = '/events/:joinCode/qr';
  static const String eventAlbum = '/events/:joinCode/album';
  static const String party = '/party';
  static const String partyCreate = '/party/create';
  static const String partyDetail = '/party/:joinCode';
  /// Join screen with no code pre-filled — manual entry + QR scanner.
  static const String joinPartyEntry = '/join';
  static const String joinParty = '/join/:joinCode';
  static const String profile = '/profile';
  static const String photoViewer = '/photo/:id';

  // --- Legal ---
  static const String termsOfService = '/legal/terms';
  static const String privacyPolicy = '/legal/privacy';

  static String albumDetailFor(String id) => '/album/$id';
  static String eventQrFor(String joinCode) => '/events/$joinCode/qr';
  static String eventAlbumFor(String joinCode) => '/events/$joinCode/album';
  static String partyDetailFor(String joinCode) => '/party/$joinCode';
  static String joinPartyFor(String joinCode) => '/join/$joinCode';
  static String photoViewerFor(String photoId, {String? albumId}) =>
      albumId == null || albumId.isEmpty
          ? '/photo/$photoId'
          : '/photo/$photoId?albumId=$albumId';
}
