import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

/// Handles album reads, writes, and photo queries.
class AlbumsController {
  /// Fetches all albums ordered by newest first.
  Future<List<AlbumModel>> fetchAlbums() async {
    if (!SupabaseService.isInitialized) {
      return const <AlbumModel>[];
    }

    final rows = await SupabaseService.client
        .from('albums')
        .select()
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => AlbumModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Fetches one album by ID.
  Future<AlbumModel?> fetchAlbumById(String albumId) async {
    if (!SupabaseService.isInitialized) {
      return null;
    }

    final row = await SupabaseService.client
        .from('albums')
        .select()
        .eq('id', albumId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return AlbumModel.fromJson(row);
  }

  /// Fetches photos for a specific album.
  Future<List<PhotoModel>> fetchAlbumPhotos(String albumId) async {
    if (!SupabaseService.isInitialized) {
      return const <PhotoModel>[];
    }

    final rows = await SupabaseService.client
        .from('photos')
        .select()
        .eq('album_id', albumId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => PhotoModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new album with the current user as creator.
  Future<AlbumModel> createAlbum({
    required String name,
    required UserModel user,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw StateError('Supabase is not initialized.');
    }

    final inserted = await SupabaseService.client
        .from('albums')
        .insert({
          'name': name.trim(),
          'created_by': user.id,
          'created_by_name': user.name,
          'photo_count': 0,
        })
        .select()
        .single();

    return AlbumModel.fromJson(inserted);
  }

  /// Sets album cover if currently empty.
  Future<void> setAlbumCoverIfEmpty({
    required String albumId,
    required String coverUrl,
  }) async {
    if (!SupabaseService.isInitialized) {
      return;
    }

    final existing = await SupabaseService.client
        .from('albums')
        .select('cover_url')
        .eq('id', albumId)
        .maybeSingle();

    final current = existing?['cover_url']?.toString();
    if (current != null && current.isNotEmpty) {
      return;
    }

    await SupabaseService.client
        .from('albums')
        .update({'cover_url': coverUrl})
        .eq('id', albumId);
  }

  /// Deletes a photo by ID if the current user is owner.
  Future<void> deletePhoto({
    required String photoId,
    required String ownerUserId,
  }) async {
    if (!SupabaseService.isInitialized) {
      return;
    }

    await SupabaseService.client
        .from('photos')
        .delete()
        .eq('id', photoId)
        .eq('uploaded_by', ownerUserId);
  }
}
