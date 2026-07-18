/// Central registry of bundled raster image asset paths.
///
/// Keeps `assets/images/*` paths out of widget code — swapping a photo
/// (e.g. the welcome screen's collage) later is a one-line change here
/// instead of a hunt through the UI.
final class AppImageAssets {
  AppImageAssets._();

  static const String _images = 'assets/images';

  // --- Welcome screen photo collage ---
  static const String welcomeCollage1 = '$_images/welcome_collage_1.jpg';
  static const String welcomeCollage2 = '$_images/welcome_collage_2.jpg';
  static const String welcomeCollage3 = '$_images/welcome_collage_3.jpg';
  static const String welcomeCollage4 = '$_images/welcome_collage_4.jpg';
  static const String welcomeCollage5 = '$_images/welcome_collage_5.jpg';
  static const String welcomeCollage6 = '$_images/welcome_collage_6.jpg';

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
