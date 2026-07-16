/// Barrel file for the shared/common layer.
///
/// Import `package:snapconnect/common/common.dart` to get the app's design
/// tokens (colors, text styles, dimensions, strings), theme helpers, and the
/// reusable widgets in one line.
library;

// Constants
export 'constants/app_dimens.dart';
export 'constants/app_strings.dart';

// Theme
export 'theme/app_semantic_colors.dart';
export 'theme/app_theme.dart';
export 'theme/context_extensions.dart';

// Design tokens that currently live under core/ (re-exported for convenience)
export 'package:snapconnect/core/constants/app_colors.dart';
export 'package:snapconnect/core/constants/app_text_styles.dart';

// Common widgets
export 'widgets/app_nav_bar.dart';
export 'widgets/app_snack_bar.dart';
export 'widgets/app_text_field.dart';

// Existing shared widgets (re-homed via re-export; low-risk, no moved files)
export 'package:snapconnect/widgets/confirm_dialog.dart';
export 'package:snapconnect/widgets/empty_state.dart';
export 'package:snapconnect/widgets/avatar_widget.dart';
export 'package:snapconnect/widgets/loading_skeleton.dart';
