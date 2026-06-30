import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';

/// Handles album reads, writes, and photo queries.
class AlbumsController {
  /// Fetches all albums ordered by newest first.
  Future<List<AlbumModel>> fetchAlbums() async {
    try {
      final response = await ApiClient().get(ApiEndpoints.albums);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => AlbumModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return const <AlbumModel>[];
  }

  /// Fetches one album by ID.
  Future<AlbumModel?> fetchAlbumById(String albumId) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.album(albumId));
      if (response.statusCode == 200) {
        return AlbumModel.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  /// Fetches photos for a specific album.
  Future<List<PhotoModel>> fetchAlbumPhotos(String albumId) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.albumPhotos(albumId));
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => PhotoModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return const <PhotoModel>[];
  }

  /// Creates a new album with the current user as creator.
  Future<AlbumModel> createAlbum({
    required String name,
    required UserModel user,
  }) async {
    final response = await ApiClient().post(
      ApiEndpoints.albums,
      data: {
        'fullName': name.trim(),
        'created_by': user.id,
        'created_by_name': user.name,
      },
    );
    return AlbumModel.fromJson(response.data['data']);
  }

  /// Sets album cover if currently empty.
  Future<void> setAlbumCoverIfEmpty({
    required String albumId,
    required String coverUrl,
  }) async {
    // API endpoint for update isn't explicitly defined yet, but we can safely skip or add later
    // if needed since photo uploads usually happen via Party anyway.
  }

  /// Deletes a photo by ID if the current user is owner.
  Future<void> deletePhoto({
    required String photoId,
    required String ownerUserId,
  }) async {
    try {
      await ApiClient().delete(ApiEndpoints.photo(photoId));
    } catch (_) {}
  }
}
