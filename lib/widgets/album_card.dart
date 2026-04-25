import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:shimmer/shimmer.dart';

/// Card widget used in album grids.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    this.index = 0,
    this.tall = true,
    this.onTap,
  });

  final AlbumModel album;
  final int index;
  final bool tall;
  final VoidCallback? onTap;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (album.id.isNotEmpty) {
      context.push('/album/${album.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final cardHeight = tall ? 220.0 : 160.0;

    return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 120),
          tween: Tween<double>(begin: 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleTap(context),
                onHighlightChanged: (_) {},
                splashColor: Colors.white.withValues(alpha: 0.14),
                child: SizedBox(
                  height: cardHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBackground(context),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              stops: const [0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.36),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${album.photoCount}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Text(
                          album.name.isEmpty ? 'Untitled' : album.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        // Laws of UX: Doherty Threshold with quick perception-friendly entry.
        .fadeIn(
          duration: disableAnimations ? 0.ms : 260.ms,
          delay: disableAnimations ? 0.ms : (index * 50).ms,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: disableAnimations ? 0.ms : 220.ms,
        );
  }

  Widget _buildBackground(BuildContext context) {
    final coverUrl = album.coverUrl?.trim();
    if (coverUrl == null || coverUrl.isEmpty) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: coverUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: const Color(0xFFE9ECEF),
        highlightColor: const Color(0xFFF8F9FA),
        child: Container(color: const Color(0xFFE9ECEF)),
      ),
      errorWidget: (context, url, error) => _placeholder(),
    );
  }

  Widget _placeholder() {
    final colors = [
      const Color(0xFF4D96FF),
      const Color(0xFF6BCB77),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFC93C),
      const Color(0xFFC77DFF),
    ];
    final name = album.name.trim();
    final color = colors[name.length % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
