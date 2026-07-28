import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:shimmer/shimmer.dart';

/// Photo card used in album and party masonry grids.
///
/// Long-press drives a Snapchat/iMessage-style reaction picker (the caller
/// owns the picker overlay — see [ReactionPickerController]); tapping the
/// overflow button opens photo actions (download/delete) instead of the
/// long-press, since long-press is taken by reactions.
class PhotoCard extends StatefulWidget {
  const PhotoCard({
    super.key,
    required this.photo,
    required this.onTap,
    this.index = 0,
    this.tall = false,
    this.highlightNew = false,
    this.onMenuTap,
    this.onReactionLongPressStart,
    this.onReactionLongPressMoveUpdate,
    this.onReactionLongPressEnd,
    this.onReactionLongPressCancel,
  });

  final PhotoModel photo;
  final VoidCallback onTap;
  final int index;
  final bool tall;
  final bool highlightNew;
  final VoidCallback? onMenuTap;
  final GestureLongPressStartCallback? onReactionLongPressStart;
  final GestureLongPressMoveUpdateCallback? onReactionLongPressMoveUpdate;
  final GestureLongPressEndCallback? onReactionLongPressEnd;
  final VoidCallback? onReactionLongPressCancel;

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final cardHeight = widget.tall ? 250.0 : 180.0;

    return GestureDetector(
      onLongPressStart: widget.onReactionLongPressStart,
      onLongPressMoveUpdate: widget.onReactionLongPressMoveUpdate,
      onLongPressEnd: widget.onReactionLongPressEnd,
      onLongPressCancel: widget.onReactionLongPressCancel,
      child: Hero(
        tag: 'photo-${widget.photo.id}',
        child: Material(
          color: Colors.transparent,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.97 : 1,
            curve: Curves.easeOut,
            child: Stack(
              children: [
                InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  onHighlightChanged: (pressed) {
                    setState(() => _pressed = pressed);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: cardHeight,
                      decoration: BoxDecoration(
                        border: widget.highlightNew
                            ? Border.all(color: AppColors.success, width: 2)
                            : Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1,
                              ), // 1px inner border per Stitch design
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.photo.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: const Color(0xFFE9ECEF),
                          highlightColor: const Color(0xFFF8F9FA),
                          child: Container(color: const Color(0xFFE9ECEF)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.onMenuTap != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: InkWell(
                          onTap: widget.onMenuTap,
                          borderRadius: BorderRadius.circular(999),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: disableAnimations ? 0.ms : 220.ms,
      delay: disableAnimations ? 0.ms : (widget.index * 35).ms,
    );
  }
}
