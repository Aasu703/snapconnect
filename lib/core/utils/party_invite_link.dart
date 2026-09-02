import 'package:snapconnect/core/constants/app_constants.dart';

/// Single source of truth for party/event invite links — building the payload
/// encoded into a QR code, and parsing whatever a scanner or the OS hands back.
///
/// QR codes encode a [scheme] deep link (`snapconnect://join/A1B2C3`) so that
/// scanning with a phone's camera opens the app directly on the join screen
/// instead of a browser. [parseJoinCode] still accepts the older
/// `<webJoinBaseUrl>/join/<code>` https form so invites already shared or
/// printed keep working.
final class PartyInviteLink {
  PartyInviteLink._();

  static const String scheme = 'snapconnect';
  static const String joinHost = 'join';

  /// Payload encoded into an invite QR code.
  static String deepLinkFor(String joinCode) =>
      '$scheme://$joinHost/${joinCode.toUpperCase()}';

  /// Human-shareable https link, used in share sheets so recipients without
  /// the app installed still land somewhere useful.
  static String webLinkFor(String joinCode) =>
      '${AppConstants.webJoinBaseUrl}/join/${joinCode.toUpperCase()}';

  static final RegExp _codePattern = RegExp(r'^[A-Za-z0-9]{6}$');

  /// Extracts a join code from a QR payload, deep link, or hand-typed string.
  ///
  /// Returns null when [payload] holds nothing that looks like a join code, so
  /// callers can ignore unrelated barcodes rather than acting on garbage.
  static String? parseJoinCode(String payload) {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) return null;

    // Dart normalizes scheme/host to lowercase but preserves path-segment
    // case, so match the structure first and uppercase only the code.
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final segments = uri.pathSegments;
      final isDeepLink = uri.scheme == scheme && uri.host == joinHost;
      final isWebLink = segments.length >= 2 &&
          segments[segments.length - 2].toLowerCase() == joinHost;

      if (isDeepLink || isWebLink) {
        final candidate = segments.last;
        return _codePattern.hasMatch(candidate) ? candidate.toUpperCase() : null;
      }
    }

    if (_codePattern.hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }

    return null;
  }
}
