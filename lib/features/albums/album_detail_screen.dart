import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/services/download_service.dart';
import 'package:snapconnect/widgets/confirm_dialog.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';
import 'package:snapconnect/widgets/photo_grid.dart';
import 'package:snapconnect/widgets/reaction_bar.dart';

/// Screen showing one album with photo grid and actions.
class AlbumDetailScreen extends ConsumerStatefulWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Keeps party/album feeds fresh with periodic refresh.
    _refreshTimer = Timer.periodic(AppConstants.partyRefreshInterval, (_) {
      ref.invalidate(albumDetailProvider(widget.albumId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Displays actions for one selected photo.
  Future<void> _showPhotoActions(PhotoModel photo) async {
    final user = ref.read(sessionProvider);

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Download'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await DownloadService.instance.downloadSinglePhoto(photo.url);
                },
              ),
              if (user != null && photo.uploadedBy == user.id)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete photo'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    final confirmed = await ConfirmDialog.show(
                      this.context,
                      title: 'Delete photo',
                      message: 'This action cannot be undone.',
                      confirmLabel: 'Delete',
                    );

                    if (!confirmed) {
                      return;
                    }

                    await ref
                        .read(albumsControllerProvider)
                        .deletePhoto(photoId: photo.id, ownerUserId: user.id);
                    ref.invalidate(albumDetailProvider(widget.albumId));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Downloads all photos in this album as a ZIP file.
  Future<void> _downloadAll(List<PhotoModel> photos) async {
    await DownloadService.instance.downloadAlbumAsZip(
      photos: photos,
      albumName: 'album_${widget.albumId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(albumDetailProvider(widget.albumId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Details'),
        actions: [
          IconButton(
            tooltip: 'Upload',
            icon: const Icon(Icons.upload_rounded),
            onPressed: () => context.push('/upload?albumId=${widget.albumId}'),
          ),
          IconButton(
            tooltip: 'Download all',
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: () async {
              final photos = await ref.read(
                albumDetailProvider(widget.albumId).future,
              );
              await _downloadAll(photos);
            },
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('Check this album in SnapConnect: ${widget.albumId}');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(albumDetailProvider(widget.albumId)),
        child: photosAsync.when(
          loading: () => const LoadingSkeleton(),
          error: (error, _) => EmptyState(
            title: 'Could not load photos',
            subtitle: error.toString(),
            icon: Icons.error_outline,
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(albumDetailProvider(widget.albumId)),
          ),
          data: (photos) {
            if (photos.isEmpty) {
              return EmptyState(
                title: 'This album is empty',
                subtitle: 'Upload your first photo to get started.',
                icon: Icons.photo_outlined,
                actionLabel: 'Upload photo',
                onAction: () =>
                    context.push('/upload?albumId=${widget.albumId}'),
              );
            }

            return PhotoGrid(
              photos: photos,
              onPhotoTap: (photo) =>
                  context.push('/photo/${photo.id}?albumId=${photo.albumId}'),
              onPhotoLongPress: _showPhotoActions,
              footerBuilder: (photo) => ReactionBar(photoId: photo.id),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload?albumId=${widget.albumId}'),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
