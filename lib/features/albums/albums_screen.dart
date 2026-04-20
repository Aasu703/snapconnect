import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/album_card.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';

/// Home screen that displays all albums in a responsive masonry grid.
class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  /// Ensures user identity before creating albums.
  Future<void> _createAlbum(BuildContext context, WidgetRef ref) async {
    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Album creation needs your identity to track ownership.',
      );
    }

    if (ref.read(sessionProvider) == null || !context.mounted) {
      return;
    }

    context.push('/album/create');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(albumsProvider),
        child: albumsAsync.when(
          loading: () {
            final width = MediaQuery.sizeOf(context).width;
            final columns = width >= 1200
                ? 4
                : width >= 840
                ? 3
                : 2;
            return LoadingSkeleton(columns: columns);
          },
          error: (error, _) {
            return EmptyState(
              title: 'Could not load albums',
              subtitle: error.toString(),
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(albumsProvider),
            );
          },
          data: (albums) {
            if (albums.isEmpty) {
              return EmptyState(
                title: 'No albums yet',
                subtitle:
                    'Create your first album and start collecting memories.',
                icon: Icons.photo_library_outlined,
                actionLabel: 'Create your first album',
                onAction: () => _createAlbum(context, ref),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1200
                    ? 4
                    : constraints.maxWidth >= 840
                    ? 3
                    : 2;

                return MasonryGridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return AlbumCard(
                          album: album,
                          onTap: () => context.push('/album/${album.id}'),
                        )
                        .animate(delay: Duration(milliseconds: 30 * index))
                        .fadeIn(duration: 200.ms)
                        .scaleXY(begin: 0.95, end: 1);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAlbum(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Create Album'),
      ),
    );
  }
}
