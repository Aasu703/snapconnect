import 'package:flutter/material.dart';

/// Centralized color tokens used by the whole app.
final class AppColors {
  AppColors._();

  // --- Stitch Design System Colors ---
  static const surface = Color(0xFFFBF8FF);
  static const surfaceDim = Color(0xFFD9D9E8);
  static const surfaceBright = Color(0xFFFBF8FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F2FF);
  static const surfaceContainer = Color(0xFFEDECFC);
  static const surfaceContainerHigh = Color(0xFFE8E7F6);
  static const surfaceContainerHighest = Color(0xFFE2E1F0);
  
  static const onSurface = Color(0xFF1A1B25);
  static const onSurfaceVariant = Color(0xFF46464F);
  
  static const inverseSurface = Color(0xFF2E303B);
  static const inverseOnSurface = Color(0xFFF0EFFF);
  
  static const outline = Color(0xFF777680);
  static const outlineVariant = Color(0xFFC7C5D0);
  static const surfaceTint = Color(0xFF565B8A);
  
  static const primary = Color(0xFF030735); // Dark Navy
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1A1F4B);
  static const onPrimaryContainer = Color(0xFF8287B9);
  static const inversePrimary = Color(0xFFBEC3F9);
  
  static const secondary = Color(0xFF4553C1); // Indigo
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF7E8CFE);
  static const onSecondaryContainer = Color(0xFF061991);
  
  static const tertiary = Color(0xFF00120A);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF002A1C); // Teal Green
  static const onTertiaryContainer = Color(0xFF1C9D74);
  
  static const error = Color(0xFFBA1A1A); // Coral Red
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  
  static const background = Color(0xFFFBF8FF);
  static const onBackground = Color(0xFF1A1B25);

  // --- Backward Compatibility Aliases ---
  static const success = tertiaryContainer;
  static const danger = error;
  static const warning = Color(0xFFFFC93C); // Kept from original for warning
  static const border = outlineVariant;
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;

  static const darkSurface = Color(0xFF111827);
  static const darkBackground = Color(0xFF0F172A);
  static const darkBorder = Color(0xFF1F2937);
  static const darkTextPrimary = Color(0xFFF3F4F6);
  static const darkTextSecondary = Color(0xFF9CA3AF);

  static const avatarColors = <Color>[
    Color(0xFFFF6B6B),
    Color(0xFFFF8E53),
    Color(0xFFFFC93C),
    success,
    secondary,
    Color(0xFFC77DFF),
    Color(0xFFFF6FD8),
    onTertiaryContainer,
    Color(0xFFF72585),
    secondaryContainer,
    Color(0xFFFB5607),
    primary,
  ];

  /// Deep navy → blue brand gradient used on always-dark branded surfaces
  /// (splash, onboarding, guest landing, QR share). Intentionally fixed in
  /// both light and dark themes — these screens are designed dark-on-gradient.
  static const brandGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
  ];

  // Gradients replaced with solid primary/secondary for minimalist aesthetic
  static const gradientPrimary = [primary, secondary];
  static const gradientHost = [secondary, secondaryContainer];
  static const gradientGuest = [tertiaryContainer, onTertiaryContainer];
  static const gradientDark = [primary, primaryContainer];

  /// Vivid purple used as a gradient companion accent on the dark "glass"
  /// screens (host dashboard, event album, guest landing, upload success).
  static const accentPurple = Color(0xFF6C63FF);

  static const accent = secondary;
  static const hostAccent = secondary;
  static const guestAccent = tertiaryContainer;
}
