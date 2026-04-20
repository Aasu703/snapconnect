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
        title: 'No photos yet',
        subtitle: 'Upload your first memory to start this album.',
        icon: Icons.photo_camera_back_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 5
            : width >= 900
                ? 4
                : width >= 680
                    ? 3
                    : 2;

        return MasonryGridView.count(
          padding: padding,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          crossAxisCount: columns,
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoCard(
                  photo: photo,
                  onTap: () => onPhotoTap(photo),
                  onLongPress:
                      onPhotoLongPress == null ? null : () => onPhotoLongPress!(photo),
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
