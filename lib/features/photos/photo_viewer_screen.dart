import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/services/download_service.dart';
import 'package:snapconnect/core/utils/date_formatter.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/loading_skeleton.dart';
import 'package:snapconnect/widgets/reaction_bar.dart';

/// Full-screen photo viewer with swipe, zoom, and reactions.
class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.photoId,
    required this.albumId,
  });

  final String photoId;
  final String albumId;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  PageController? _pageController;
  int _currentIndex = 0;
  bool _initialized = false;
  bool _showChrome = true;
  double _verticalDragOffset = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// Initializes page index once photo list becomes available.
  void _initPageController(List<dynamic> photos) {
    if (_initialized) {
      return;
    }

    final initialIndex = photos.indexWhere(
      (photo) => photo.id == widget.photoId,
    );
    _currentIndex = initialIndex < 0 ? 0 : initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(albumDetailProvider(widget.albumId));
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final dismissProgress = (_verticalDragOffset / 350).clamp(0.0, 1.0);
    final viewerScale = 1 - (dismissProgress * 0.18);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _showChrome = !_showChrome),
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          setState(() {
            _verticalDragOffset = (_verticalDragOffset + details.delta.dy).clamp(
              0,
              420,
            );
          });
        }
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 500 || _verticalDragOffset > 170) {
          context.pop();
          return;
        }

        setState(() => _verticalDragOffset = 0);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: photosAsync.when(
          loading: () => const Center(
            child: PhotoGridSkeleton(
              itemCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(18),
            ),
          ),
          error: (error, _) => EmptyState(
            title: 'Could not open photo',
            subtitle: error.toString(),
            icon: Icons.error_outline,
            actionLabel: 'Back',
            onAction: () => context.pop(),
          ),
          data: (photos) {
            if (photos.isEmpty) {
              return EmptyState(
                title: 'No photo found',
                subtitle: 'This album has no photos to preview.',
                icon: Icons.photo_outlined,
                actionLabel: 'Back',
                onAction: () => context.pop(),
              );
            }

            _initPageController(photos);
            final photo = photos[_currentIndex];

            return Stack(
              children: [
                Transform.translate(
                  offset: Offset(0, _verticalDragOffset),
                  child: Transform.scale(
                    scale: viewerScale,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: photos.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        final item = photos[index];
                        return Hero(
                          tag: 'photo-${item.id}',
                          child: PhotoView(
                            imageProvider: NetworkImage(item.url),
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 3,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  top: _showChrome ? 0 : -120,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.62),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: 72,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => DownloadService.instance
                                  .downloadSinglePhoto(photo.url),
                              icon: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Share.share(photo.url),
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  bottom: _showChrome ? 0 : -220,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.title?.isNotEmpty == true
                                  ? photo.title!
                                  : 'Photo ${_currentIndex + 1} of ${photos.length}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                              Text(
                                'Uploaded by ${photo.uploadedByName} - ${DateFormatter.relative(photo.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            ReactionBar(photoId: photo.id),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
