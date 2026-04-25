import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:shimmer/shimmer.dart';

/// Photo card used in album and party masonry grids.
class PhotoCard extends StatefulWidget {
  const PhotoCard({
    super.key,
    required this.photo,
    required this.onTap,
    this.index = 0,
    this.tall = false,
    this.highlightNew = false,
    this.onLongPress,
  });

  final PhotoModel photo;
  final VoidCallback onTap;
  final int index;
  final bool tall;
  final bool highlightNew;
  final VoidCallback? onLongPress;

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final cardHeight = widget.tall ? 250.0 : 180.0;

    return Hero(
          tag: 'photo-${widget.photo.id}',
          child: Material(
            color: Colors.transparent,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: _pressed ? 0.97 : 1,
              curve: Curves.easeOut,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                borderRadius: BorderRadius.circular(14),
                onHighlightChanged: (pressed) {
                  setState(() => _pressed = pressed);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: cardHeight,
                    decoration: BoxDecoration(
                      border: widget.highlightNew
                          ? Border.all(color: const Color(0xFF6BCB77), width: 2)
                          : null,
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
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: disableAnimations ? 0.ms : 220.ms,
          delay: disableAnimations ? 0.ms : (widget.index * 35).ms,
        );
  }
}
