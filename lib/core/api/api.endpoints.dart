import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // configure base URL based on platform
  static const bool isPhysicalDevice =
      false; // Set to true for physical device testing, false for emulator/simulator
  static const String _ipAddress = '192.168.1.7';
  static const int _port = 3000;

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
}
