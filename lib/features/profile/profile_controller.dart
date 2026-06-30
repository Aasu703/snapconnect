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
}
