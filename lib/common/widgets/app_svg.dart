import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Single entry point for rendering bundled SVG assets.
///
/// Every call site should render SVGs through this widget (with a path from
/// [AppSvgAssets]) instead of calling `SvgPicture.asset` directly, so sizing
/// defaults, error handling, and the underlying rendering package are all
/// controlled from one place and can change without touching call sites.
class AppSvg extends StatelessWidget {
  const AppSvg(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.colorFilter,
    this.semanticsLabel,
  });

  /// Path into `assets/images/`, e.g. from [AppSvgAssets].
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter,
      semanticsLabel: semanticsLabel,
      placeholderBuilder: (context) => SizedBox(width: width, height: height),
    );
  }
}
