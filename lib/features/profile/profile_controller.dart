import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

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
  Future<ProfileStats> fetchStats(String userId) async {
    if (!SupabaseService.isInitialized) {
      return const ProfileStats(photosUploaded: 0, albumsCreated: 0, partiesJoined: 0);
    }

    final photos = await SupabaseService.client
        .from('photos')
        .select('id')
        .eq('uploaded_by', userId);

    final albums = await SupabaseService.client
        .from('albums')
        .select('id')
        .eq('created_by', userId);

    final parties = await SupabaseService.client
        .from('party_members')
        .select('id')
        .eq('user_id', userId);

    return ProfileStats(
      photosUploaded: (photos as List<dynamic>).length,
      albumsCreated: (albums as List<dynamic>).length,
      partiesJoined: (parties as List<dynamic>).length,
    );
  }

  /// Updates the display name in Supabase and returns updated local model.
  Future<UserModel> updateName(UserModel user, String newName) async {
    final value = newName.trim();
    if (value.isEmpty) {
      return user;
    }

    if (SupabaseService.isInitialized && (user.email?.isNotEmpty ?? false)) {
      await SupabaseService.client
          .from('users')
          .upsert({'id': user.id, 'name': value, 'email': user.email});
    }

    return user.copyWith(name: value);
  }

  /// Adds or updates an email for cross-device identity restoration.
  Future<UserModel> addEmail(UserModel user, String email) async {
    final value = email.trim().toLowerCase();
    if (value.isEmpty) {
      return user;
    }

    if (SupabaseService.isInitialized) {
      await SupabaseService.client.from('users').upsert({
        'id': user.id,
        'name': user.name,
        'email': value,
        'avatar_color': user.avatarColor,
      });
    }

    return user.copyWith(email: value);
  }
}
