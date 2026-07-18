import 'package:flutter/material.dart';
import 'package:snapconnect/core/constants/app_colors.dart';

/// App-specific semantic colors that are NOT part of Material's [ColorScheme]
/// but still must flip between light and dark themes.
///
/// Access via `Theme.of(context).extension<AppSemanticColors>()!` or the
/// `context.appColors` extension. Registering these here means every screen
/// stops hardcoding hex values that break the dark-mode toggle.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.screenBackground,
    required this.cardBackground,
    required this.cardBorder,
    required this.mutedText,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// Scaffold / page background.
  final Color screenBackground;

  /// Surface for cards, tiles, and containers.
  final Color cardBackground;

  /// Hairline border around cards and containers.
  final Color cardBorder;

  /// De-emphasized text (captions, placeholders, secondary labels).
  final Color mutedText;

  /// Highlight color for icons and interactive accents.
  final Color accent;

  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppSemanticColors(
    screenBackground: Color(0xFFF8F9FA),
    cardBackground: AppColors.surfaceContainerLowest,
    cardBorder: Color(0xFFE3E5E8),
    mutedText: AppColors.onSurfaceVariant,
    accent: AppColors.secondary,
    success: AppColors.onTertiaryContainer,
    warning: AppColors.warning,
    danger: AppColors.error,
  );

  static const dark = AppSemanticColors(
    screenBackground: AppColors.darkBackground,
    cardBackground: AppColors.darkSurface,
    cardBorder: AppColors.darkBorder,
    mutedText: AppColors.darkTextSecondary,
    accent: AppColors.secondaryContainer,
    success: AppColors.onTertiaryContainer,
    warning: AppColors.warning,
    danger: AppColors.error,
  );

  @override
  AppSemanticColors copyWith({
    Color? screenBackground,
    Color? cardBackground,
    Color? cardBorder,
    Color? mutedText,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppSemanticColors(
      screenBackground: screenBackground ?? this.screenBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      mutedText: mutedText ?? this.mutedText,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      screenBackground:
          Color.lerp(screenBackground, other.screenBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
