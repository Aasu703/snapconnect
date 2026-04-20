import 'package:flutter/material.dart';
import 'package:snapconnect/core/constants/app_colors.dart';

/// Utility helpers for avatar initials and deterministic avatar colors.
final class AvatarHelper {
  AvatarHelper._();

  /// Picks a deterministic color from input text.
  static Color colorFromSeed(String value) {
    final clean = value.trim().toLowerCase();
    final index = clean.isEmpty ? 0 : clean.hashCode.abs() % AppColors.avatarColors.length;
    return AppColors.avatarColors[index];
  }

  /// Converts deterministic avatar color to a hex string.
  static String colorHexFromSeed(String value) {
    final color = colorFromSeed(value);
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Converts a persisted color hex string into a color instance.
  static Color colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) {
      return AppColors.primary;
    }

    final normalized = hex.replaceAll('#', '');
    final value = normalized.length == 8 ? normalized : 'FF$normalized';
    return Color(int.parse(value, radix: 16));
  }

  /// Returns two-letter initials from a display name.
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((value) => value.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'G';
    }

    if (parts.length == 1) {
      final part = parts.first;
      return part.length == 1 ? part.toUpperCase() : part.substring(0, 2).toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
