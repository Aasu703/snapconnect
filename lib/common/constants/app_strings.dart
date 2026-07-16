/// Frequently used, non-localized user-facing strings.
///
/// Centralizing these keeps copy consistent and makes a future migration to a
/// localization framework (e.g. `flutter_localizations` / `.arb`) a mechanical
/// find-and-replace instead of a codebase-wide hunt.
final class AppStrings {
  AppStrings._();

  // --- App ---
  static const String appName = 'SnapConnect';

  // --- Generic actions ---
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String download = 'Download';
  static const String continueLabel = 'Continue';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';
  static const String logout = 'Logout';
  static const String comingSoon = 'Coming soon!';

  // --- Navigation / sections ---
  static const String albums = 'Albums';
  static const String events = 'Events';
  static const String parties = 'Parties';
  static const String profile = 'Profile';
  static const String upload = 'Upload';

  // --- Profile ---
  static const String editName = 'Edit name';
  static const String addEmail = 'Add email';
  static const String updateEmail = 'Update email';
  static const String saveProfile = 'Save Profile';
  static const String setUpProfile = 'Set up your profile';
  static const String setUpProfileSubtitle =
      'Add your name so albums, parties, and uploads show who you are.';
  static const String darkMode = 'Dark mode';
  static const String noEmailSet = 'No email set';
  static const String emailOptional = 'Email (optional)';
  static const String name = 'Name';
  static const String displayNameHint = 'Your display name';
  static const String emailHint = 'you@example.com';
  static const String profileSetupFailed = 'Could not set up your profile.';

  // --- Albums / parties / events ---
  static const String createAlbum = 'Create Album';
  static const String createParty = 'Create Party';
  static const String joinParty = 'Join Party';
  static const String findParty = 'Find Party';
  static const String uploadPhotos = 'Upload Photos';
  static const String pickPhotos = 'Pick Photos';
  static const String takePhoto = 'Take Photo';
  static const String shareInviteLink = 'Share Invite Link';

  // --- Common errors / prompts ---
  static const String uploadFailed = 'Upload failed. Please try again.';
  static const String pleaseSignInFirst = 'Please sign in first';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String fixHighlightedFields =
      'Please fix the highlighted fields.';
}
