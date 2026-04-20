import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global app constants, environment variables, and upload constraints.
final class AppConstants {
  AppConstants._();

  static const int maxUploadPhotos = 20;
  static const int maxUploadBytes = 10 * 1024 * 1024;
  static const String defaultCloudinaryFolder = 'album/flutter';
  static const Duration partyRefreshInterval = Duration(seconds: 15);

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static String get cloudinaryFolder =>
      dotenv.env['CLOUDINARY_FOLDER'] ?? defaultCloudinaryFolder;

  static String get webJoinBaseUrl =>
      dotenv.env['WEB_JOIN_BASE_URL'] ?? 'https://your-web-app.vercel.app';

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasCloudinaryConfig =>
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty;
}
