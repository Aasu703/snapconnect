import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/widgets/empty_state.dart';
import 'package:snapconnect/widgets/photo_card.dart';

/// Responsive masonry photo grid with optional per-item footer.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onPhotoLongPress,
    this.footerBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  final List<PhotoModel> photos;
  final void Function(PhotoModel photo) onPhotoTap;
  final void Function(PhotoModel photo)? onPhotoLongPress;
  final Widget Function(PhotoModel photo)? footerBuilder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const EmptyState(
        emoji: '🌅',
        title: 'No photos yet',
        subtitle: 'Be the first to upload!',
        icon: Icons.photo_camera_back_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 900
            ? 4
            : width >= 600
            ? 3
            : 2;

        return MasonryGridView.count(
          padding: padding,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: columns,
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            final isTall = index % 4 == 0 || index % 4 == 3;
            final isNew =
                DateTime.now().difference(photo.createdAt).inSeconds <= 3;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoCard(
                  photo: photo,
                  index: index,
                  tall: isTall,
                  highlightNew: isNew,
                  onTap: () => onPhotoTap(photo),
                  onLongPress: onPhotoLongPress == null
                      ? null
                      : () => onPhotoLongPress!(photo),
                ),
                if (footerBuilder != null) footerBuilder!(photo),
              ],
            );
          },
        );
      },
    );
  }
}
