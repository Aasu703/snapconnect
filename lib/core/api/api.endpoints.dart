import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // configure base URL based on platform
  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.1.7';
  static const int _port = 5050;

  // Base URL configuration
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port/';
  static String get socketUrl => 'http://$_host:$_port';
  static String get baseUrl => '${serverUrl}api/';
  static String get mediaUrl => '${serverUrl}media/';
  static String get uploadsUrl => '${serverUrl}uploads/';

  static String resolveMediaUrl(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return mediaUrl;

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      return trimmed;
    }

    var normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;

    // Backward compatibility for incorrectly prefixed persisted paths.
    if (normalized.startsWith('media/uploads/')) {
      normalized = normalized.substring('media/'.length);
    }

    if (normalized.startsWith('uploads/')) {
      return '$serverUrl$normalized';
    }
    if (normalized.startsWith('media/')) {
      return '$serverUrl$normalized';
    }

    return '$mediaUrl$normalized';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userWhoAmI = 'auth/whoami';
  static const String userUploadPhoto = 'auth/update-profile';
  static String userPicture(String filename) =>
      resolveMediaUrl('user_photos/$filename');

  // -------------------------- PARTIES -------------------------
  static const String parties = 'parties';
  static const String partyJoin = 'parties/join';
  static String party(String id) => 'parties/$id';
  static String partyByCode(String code) => 'parties/code/$code';
  static String hostParties(String userId) => 'parties/host/$userId';
  static String joinedParties(String userId) => 'parties/joined/$userId';

  // -------------------------- ALBUMS -------------------------
  static const String albums = 'albums';
  static String album(String id) => 'albums/$id';
  static String userAlbums(String userId) => 'albums/user/$userId';

  // -------------------------- PHOTOS -------------------------
  static const String photoUpload = 'photos/upload';
  static String albumPhotos(String albumId) => 'photos/album/$albumId';
  static String photo(String id) => 'photos/$id';
}
