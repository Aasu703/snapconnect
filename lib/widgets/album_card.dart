import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/widgets/avatar_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Pin-style card used in the Home masonry grid: an unobstructed cover image
/// with a small top-left count/privacy pill, and the album's name + creator
/// as a caption below the image — mirroring a Pinterest pin rather than
/// overlaying text directly on the photo.
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
    final theme = Theme.of(context);

    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: cardHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildBackground(context),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _CountPill(
                            count: album.photoCount,
                            isPrivate: album.isPrivate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AvatarWidget(
                      name: album.createdByName ?? album.fullName,
                      size: 22,
                      fontSize: 10,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        album.fullName.isEmpty ? 'Untitled' : album.fullName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (album.createdByName != null &&
                    album.createdByName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      album.createdByName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
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
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiaryContainer,
      AppColors.error,
    ];
    final fullName = album.fullName.trim();
    final color = colors[fullName.length % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Text(
          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
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

/// Small pill badge in a pin's top-left corner showing the photo count and,
/// when the album is private, a lock glyph — mirroring the collection-count
/// chip Pinterest overlays on multi-photo pins.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.isPrivate});

  final int count;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_rounded : Icons.collections_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
