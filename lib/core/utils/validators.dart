/// Shared input validators used by forms across features.
final class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');

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

  /// Validates required email values.
  static String? validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a username: required, 3-20 chars, letters/digits/dot/underscore only.
  static String? validateUsername(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Username is required';
    }
    if (text.length < 3) {
      return 'At least 3 characters';
    }
    if (text.length > 20) {
      return 'At most 20 characters';
    }
    if (!_usernameRegex.hasMatch(text)) {
      return 'Only letters, numbers, dots, and underscores';
    }
    return null;
  }

  /// Validates a required password.
  static String? validatePassword(String? value) {
    final text = value ?? '';
    if (text.trim().isEmpty) {
      return 'Password is required';
    }
    if (text.length < 6) {
      return 'At least 6 characters';
    }
    return null;
  }

  /// Validates a password being newly set (registration, password reset).
  ///
  /// Enforces 8 characters to match the backend's minimum — [validatePassword]
  /// is more lenient because it also guards sign-in against legacy accounts.
  static String? validateNewPassword(String? value) {
    final text = value ?? '';
    if (text.trim().isEmpty) {
      return 'Password is required';
    }
    if (text.length < 8) {
      return 'At least 8 characters';
    }
    return null;
  }

  /// Validates that a confirmation matches the original password.
  static String? validateConfirmPassword(String password, String? value) {
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates an optional phone number: if provided, requires at least 10 digits.
  static String? validateOptionalPhone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) {
      return 'Enter at least 10 digits';
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
