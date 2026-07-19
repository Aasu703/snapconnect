/// Centralized layout dimensions: spacing, radii, icon sizes, component
/// heights, line-height ratios, and animation durations.
///
/// Use these instead of hardcoded numbers so vertical rhythm, corner radii,
/// and touch targets stay consistent across the whole app.
final class AppDimens {
  AppDimens._();

  // --- Spacing scale (used for padding, margins, and [Gap]) ---
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space14 = 14;
  static const double space16 = 16;
  static const double space18 = 18;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space28 = 28;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // --- Semantic spacing aliases ---
  static const double xs = space4;
  static const double sm = space8;
  static const double md = space16;
  static const double lg = space24;
  static const double xl = space32;
  static const double xxl = space48;

  /// Default page padding used by scrollable screen bodies.
  static const double screenPadding = space20;

  // --- Corner radii ---
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // --- Icon sizes ---
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double iconHero = 72;

  // --- Component heights ---
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double navBarHeight = 72;
  static const double navItemHeight = 64;

  // --- Line-height ratios (multiply by font size for TextStyle.height) ---
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // --- Constraints ---
  static const double maxFormWidth = 420;
  static const double maxContentWidth = 640;

  // --- Animation durations ---
  static const Duration durationFast = Duration(milliseconds: 180);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
}
