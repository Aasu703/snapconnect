import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapconnect/widgets/album_card.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Home screen that displays all albums with explicit async states.
class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('AlbumsScreen mounted');
    _testSupabase();
  }

  Future<void> _testSupabase() async {
    try {
      final result = await Supabase.instance.client
          .from('albums')
          .select('id, name')
          .limit(1);
      debugPrint('TEST QUERY RESULT: $result');
    } catch (e) {
      debugPrint('TEST QUERY ERROR: $e');
    }
  }

  Future<void> _createAlbum() async {
    if (ref.read(sessionProvider) == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Create your identity',
        subtitle: 'Album creation needs your identity to track ownership.',
      );
    }

    if (!mounted || ref.read(sessionProvider) == null) {
      return;
    }

    context.push('/album/create');
  }

  Future<void> _refreshAlbums() async {
    ref.invalidate(albumsProvider);
    try {
      await ref.read(albumsProvider.future);
    } catch (e) {
      debugPrint('Albums refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AlbumsScreen build called');
    final albumsAsync = ref.watch(albumsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Albums',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4D96FF)),
            onPressed: _createAlbum,
          ),
        ],
      ),
      body: albumsAsync.when(
        loading: () {
          debugPrint('Albums: loading state');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          debugPrint('Albums error: $error');
          debugPrint('Stack: $stack');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load albums',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(albumsProvider),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (albums) {
          debugPrint('Albums loaded: ${albums.length} albums');

          if (albums.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 64,
                      color: Color(0xFF4D96FF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No albums yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first album to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _createAlbum,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Album'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D96FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final width = MediaQuery.sizeOf(context).width;
          final columns = width >= 1200
              ? 4
              : width >= 840
              ? 3
              : 2;

          return RefreshIndicator(
            onRefresh: _refreshAlbums,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return AlbumCard(album: album);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAlbum,
        backgroundColor: const Color(0xFF4D96FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Album'),
      ),
    );
  }
}
