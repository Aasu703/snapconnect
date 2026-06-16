import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/providers/controllers_provider.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  try {
    final client = SupabaseService.maybeClient;
    if (client == null) return const <AlbumModel>[];

    final Object response = await client
        .from('albums')
        .select('*')
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;

    return data
        .map((json) {
          try {
            return AlbumModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            debugPrint('albumsProvider: failed to parse album: $e');
            return null;
          }
        })
        .whereType<AlbumModel>()
        .toList();
  } catch (e, stack) {
    debugPrint('albumsProvider ERROR: $e\n$stack');
    rethrow;
  }
});

final albumDetailProvider = FutureProvider.family<List<PhotoModel>, String>(
  (ref, albumId) =>
      ref.watch(albumsControllerProvider).fetchAlbumPhotos(albumId),
);
