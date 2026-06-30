import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapconnect/core/constants/app_colors.dart';

/// Shared typography definitions used in light and dark themes based on Stitch Design System.
final class AppTextStyles {
  AppTextStyles._();

  static TextTheme lightTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      // headline-xl
      displayLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: AppColors.onSurface,
      ),
      // headline-lg
      displayMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: AppColors.onSurface,
      ),
      // headline-lg-mobile / headline-md fallback
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: AppColors.onSurface,
      ),
      // headline-md
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      ),
      // Custom title medium fallback
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      // body-lg
      bodyLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      ),
      // body-md
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      ),
      // body-sm
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      ),
      // label-md
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 16 / 14,
        letterSpacing: 0.01 * 14,
        color: AppColors.onPrimary,
      ),
      // label-sm
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  static TextTheme darkTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.02 * 40,
        color: AppColors.darkTextPrimary,
      ),
      displayMedium: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.darkTextSecondary,
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 16 / 14,
        letterSpacing: 0.01 * 14,
        color: AppColors.surface,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.darkTextSecondary,
      ),
    );
  }
}
