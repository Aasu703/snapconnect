import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-based skeleton grid used while content is loading.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.itemCount = 8,
    this.columns = 2,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final int columns;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AlbumGridSkeleton(
      itemCount: itemCount,
      forcedColumns: columns,
      padding: padding,
    );
  }
}

/// Album masonry skeleton that mirrors the visual rhythm of the albums feed.
class AlbumGridSkeleton extends StatelessWidget {
  const AlbumGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(8),
    this.forcedColumns,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final EdgeInsets padding;
  final int? forcedColumns;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns =
        forcedColumns ??
        (width > 900
            ? 4
            : width >= 600
            ? 3
            : 2);

    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A3445)
        : const Color(0xFFE9ECEF);
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D4A61)
        : const Color(0xFFF8F9FA);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: MasonryGridView.count(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemBuilder: (context, index) {
          final isLong = index % 3 != 1;
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: isLong ? 220 : 160,
              child: Container(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

/// Photo masonry skeleton that mirrors the album photo grid rhythm.
class PhotoGridSkeleton extends StatelessWidget {
  const PhotoGridSkeleton({
    super.key,
    this.itemCount = 8,
    this.padding = const EdgeInsets.all(8),
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 900
        ? 4
        : width >= 600
        ? 3
        : 2;
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A3445)
        : const Color(0xFFE9ECEF);
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D4A61)
        : const Color(0xFFF8F9FA);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: MasonryGridView.count(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemBuilder: (context, index) {
          final isLong = index % 4 == 0 || index % 4 == 3;
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: isLong ? 230 : 170,
              child: Container(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
