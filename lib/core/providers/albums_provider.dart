import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/providers/controllers_provider.dart';

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  try {
    return ref.watch(albumsControllerProvider).fetchAlbums();
  } catch (e, stack) {
    debugPrint('albumsProvider ERROR: $e\n$stack');
    rethrow;
  }
});

final albumDetailProvider = FutureProvider.family<List<PhotoModel>, String>(
  (ref, albumId) =>
      ref.watch(albumsControllerProvider).fetchAlbumPhotos(albumId),
);
