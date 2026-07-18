/// Central registry of bundled SVG asset paths.
///
/// Keeps `assets/images/*.svg` paths out of widget code — swapping an
/// illustration (e.g. the welcome screen's photo collage, or the app logo,
/// once it becomes an SVG) later is a one-line change here instead of a
/// hunt through the UI. Render these through [AppSvg], not `SvgPicture`
/// directly, so there's a single place controlling how SVGs load.
final class AppSvgAssets {
  AppSvgAssets._();

  static const String _images = 'assets/images';

  // --- Welcome screen photo collage ---
  static const String welcomeCollage1 = '$_images/image.svg';
  static const String welcomeCollage2 = '$_images/image-1.svg';
  static const String welcomeCollage3 = '$_images/image-2.svg';
  static const String welcomeCollage4 = '$_images/image-3.svg';
  static const String welcomeCollage5 = '$_images/image-4.svg';
  static const String welcomeCollage6 = '$_images/image-5.svg';

  /// All welcome-collage tiles, in display order.
  static const List<String> welcomeCollageTiles = [
    welcomeCollage1,
    welcomeCollage2,
    welcomeCollage3,
    welcomeCollage4,
    welcomeCollage5,
    welcomeCollage6,
  ];
}
