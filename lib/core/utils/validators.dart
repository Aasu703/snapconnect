/// Shared input validators used by forms across features.
final class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates required display names.
  static String? validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Name is required';
    }
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates optional email values.
  static String? validateOptionalEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a six-character party join code.
  static String? validateJoinCode(String? value) {
    final text = (value ?? '').trim().toUpperCase();
    if (text.length != 6) {
      return 'Join code must be 6 characters';
    }
    return null;
  }
}
