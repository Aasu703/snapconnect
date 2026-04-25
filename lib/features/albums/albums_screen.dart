import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/album_card.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';

enum _AlbumFilter { all, recent, parties, mine }

/// Home screen that displays albums in a Pinterest-style masonry feed.
class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  _AlbumFilter _selectedFilter = _AlbumFilter.all;

  @override
  void initState() {
    super.initState();
    debugPrint('AlbumsScreen mounted');
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
    final user = ref.watch(sessionProvider);
    final albumsAsync = ref.watch(albumsProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget bodyForState = albumsAsync.when(
      loading: () => _buildScrollLayout(
        userName: user?.name,
        contentSlivers: [
          const SliverToBoxAdapter(
            child: AlbumGridSkeleton(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
      error: (error, stack) {
        debugPrint('Albums error: $error');
        debugPrint('Albums stack: $stack');
        return _buildScrollLayout(
          userName: user?.name,
          contentSlivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load albums',
                subtitle: error.toString(),
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(albumsProvider),
              ),
            ),
          ],
        );
      },
      data: (albums) {
        final filteredAlbums = _applyFilter(
          albums: albums,
          selectedFilter: _selectedFilter,
          currentUserId: user?.id,
        );

        if (filteredAlbums.isEmpty) {
          return _buildScrollLayout(
            userName: user?.name,
            contentSlivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  emoji: '📷',
                  title: 'No albums yet',
                  subtitle: 'Create one and start capturing memories',
                  actionLabel: 'Create Album',
                  onAction: _createAlbum,
                ),
              ),
            ],
          );
        }

        return _buildScrollLayout(
          userName: user?.name,
          contentSlivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: _responsiveColumns(
                  MediaQuery.sizeOf(context).width,
                ),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: filteredAlbums.length,
                itemBuilder: (context, index) {
                  final isLong = index % 3 != 1;
                  return AlbumCard(
                    album: filteredAlbums[index],
                    index: index,
                    tall: isLong,
                  );
                },
              ),
            ),
            // Laws of UX: Serial Position Effect with end spacing above bottom nav.
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshAlbums,
        child: bodyForState,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAlbum,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Album'),
      ),
      floatingActionButtonAnimator: disableAnimations
          ? FloatingActionButtonAnimator.noAnimation
          : FloatingActionButtonAnimator.scaling,
    );
  }

  List<AlbumModel> _applyFilter({
    required List<AlbumModel> albums,
    required _AlbumFilter selectedFilter,
    required String? currentUserId,
  }) {
    switch (selectedFilter) {
      case _AlbumFilter.all:
        return albums;
      case _AlbumFilter.recent:
        return albums.take(30).toList();
      case _AlbumFilter.parties:
        return albums.where((album) {
          final name = album.name.toLowerCase();
          final creator = album.createdByName?.toLowerCase() ?? '';
          return name.contains('party') || creator.contains('party');
        }).toList();
      case _AlbumFilter.mine:
        if (currentUserId == null) {
          return <AlbumModel>[];
        }
        return albums
            .where((album) => album.createdBy == currentUserId)
            .toList();
    }
  }

  int _responsiveColumns(double width) {
    if (width > 900) {
      return 4;
    }
    if (width >= 600) {
      return 3;
    }
    // Laws of UX: Miller's Law, max 2 columns on mobile.
    return 2;
  }

  Widget _buildScrollLayout({
    required String? userName,
    required List<Widget> contentSlivers,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 84,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
            title: Text(
              'Album',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon.')),
                );
              },
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: AvatarWidget(name: userName ?? 'Guest', size: 34),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterPill(
                  label: 'All',
                  selected: _selectedFilter == _AlbumFilter.all,
                  onTap: () =>
                      setState(() => _selectedFilter = _AlbumFilter.all),
                ),
                _FilterPill(
                  label: 'Recent',
                  selected: _selectedFilter == _AlbumFilter.recent,
                  onTap: () =>
                      setState(() => _selectedFilter = _AlbumFilter.recent),
                ),
                _FilterPill(
                  label: 'Parties',
                  selected: _selectedFilter == _AlbumFilter.parties,
                  onTap: () =>
                      setState(() => _selectedFilter = _AlbumFilter.parties),
                ),
                _FilterPill(
                  label: 'My Albums',
                  selected: _selectedFilter == _AlbumFilter.mine,
                  onTap: () =>
                      setState(() => _selectedFilter = _AlbumFilter.mine),
                ),
              ],
            ),
          ),
        ),
        ...contentSlivers,
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
