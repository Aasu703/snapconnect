import 'package:flutter/material.dart';
import 'package:snapconnect/common/constants/app_dimens.dart';
import 'package:snapconnect/common/theme/context_extensions.dart';

/// One place to show snackbars so every toast looks and behaves the same.
///
/// Replaces the scattered `ScaffoldMessenger.of(context).showSnackBar(...)`
/// calls throughout the app. Colors are theme-aware and flip with dark mode.
final class AppSnackBar {
  AppSnackBar._();

  static void showInfo(BuildContext context, String message) {
    _show(context, message, context.colors.inverseSurface,
        context.colors.onInverseSurface);
  }

  static void showSuccess(BuildContext context, String message) {
    final background = context.appColors.success;
    _show(context, message, background, _foregroundFor(background));
  }

  static void showError(BuildContext context, String message) {
    final background = context.appColors.danger;
    _show(context, message, background, _foregroundFor(background));
  }

  /// Picks a legible black/white foreground for a given background so
  /// snackbar text stays readable in both light and dark theme.
  static Color _foregroundFor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static void _show(
    BuildContext context,
    String message,
    Color background,
    Color foreground,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: foreground)),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
        ),
      );
  }
}
