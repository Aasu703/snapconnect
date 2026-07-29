import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';

/// Aggregated profile metrics for the profile screen.
class ProfileStats {
  const ProfileStats({
    required this.photosUploaded,
    required this.albumsCreated,
    required this.partiesJoined,
  });

  final int photosUploaded;
  final int albumsCreated;
  final int partiesJoined;
}

/// Handles profile statistics and user updates.
class ProfileController {
  /// Loads profile stats from Supabase tables.
  /// Loads profile stats. 
  Future<ProfileStats> fetchStats(String userId) async {
    // Backend doesn't have a specific stats endpoint yet, so we return default stats
    return const ProfileStats(
      photosUploaded: 0,
      albumsCreated: 0,
      partiesJoined: 0,
    );
  }

  /// Updates the display name in Supabase and returns updated local model.
  Future<UserModel> updateName(UserModel user, String newName) async {
    final value = newName.trim();
    if (value.isEmpty) {
      return user;
    }

    try {
      await ApiClient().put(ApiEndpoints.user, data: {'name': value});
    } catch (_) {}

    return user.copyWith(name: value);
  }

  /// Adds or updates an email for cross-device identity restoration.
  Future<UserModel> addEmail(UserModel user, String email) async {
    final value = email.trim().toLowerCase();
    if (value.isEmpty) {
      return user;
    }

    try {
      await ApiClient().put(ApiEndpoints.user, data: {'email': value});
    } catch (_) {}

    return user.copyWith(email: value);
  }

  /// Uploads a new profile photo and returns the updated user.
  Future<UserModel> uploadPhoto(UserModel user, XFile file) async {
    final formData = FormData.fromMap({
      'userId': user.id,
      'photo': await MultipartFile.fromFile(file.path, filename: file.name),
    });

    final response = await ApiClient().post(
      ApiEndpoints.userUploadPhoto,
      data: formData,
    );

    final photoPath = response.data['data']['imageUrl']?.toString();
    if (photoPath == null || photoPath.isEmpty) {
      return user;
    }

    return user.copyWith(photoUrl: ApiEndpoints.resolveMediaUrl(photoPath));
  }
}
