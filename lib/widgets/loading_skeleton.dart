import 'package:flutter/material.dart';
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
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.grey.shade300;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        padding: padding,
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(color: Colors.white),
          );
        },
      ),
    );
  }
}
