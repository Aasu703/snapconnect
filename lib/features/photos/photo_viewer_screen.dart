import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/services/download_service.dart';
import 'package:snapconnect/core/utils/date_formatter.dart';
import 'package:snapconnect/widgets/empty_state.dart';
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

    final initialIndex = photos.indexWhere((photo) => photo.id == widget.photoId);
    _currentIndex = initialIndex < 0 ? 0 : initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(albumDetailProvider(widget.albumId));

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: photosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
                PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final item = photos[index];
                    return Hero(
                      tag: 'photo-${item.id}',
                      child: PhotoView(
                        imageProvider: NetworkImage(item.url),
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      ),
                    );
                  },
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => DownloadService.instance.downloadSinglePhoto(photo.url),
                            icon: const Icon(Icons.download_rounded, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () => Share.share(photo.url),
                            icon: const Icon(Icons.share_outlined, color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.62),
                          border: Border(
                            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.title?.isNotEmpty == true
                                  ? photo.title!
                                  : 'Photo ${_currentIndex + 1} of ${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded by ${photo.uploadedByName} • ${DateFormatter.relative(photo.createdAt)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            ReactionBar(photoId: photo.id),
                          ],
                        ),
                      ),
                    ],
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
