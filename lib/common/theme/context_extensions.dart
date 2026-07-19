import 'package:flutter/material.dart';
import 'package:snapconnect/common/theme/app_semantic_colors.dart';

/// Ergonomic theme accessors so widgets can read `context.colors.primary`,
/// `context.text.titleLarge`, and `context.appColors.cardBackground` instead
/// of the verbose `Theme.of(context)...` chains — and never hardcode a hex.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Material color roles (primary, surface, error, outlineVariant, ...).
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Typographic scale (displayLarge, titleLarge, bodyMedium, ...).
  TextTheme get text => Theme.of(this).textTheme;

  /// App-specific semantic colors that flip with the theme
  /// (screenBackground, cardBackground, cardBorder, mutedText, success, ...).
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
