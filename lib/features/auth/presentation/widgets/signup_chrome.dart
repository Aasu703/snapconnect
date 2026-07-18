import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/common/common.dart';

/// Fixed top bar shown above every step after the welcome screen: a back
/// caret plus a centered "Sign up" title, mirroring the sliding step flow's
/// persistent chrome so only the field content underneath animates.
class SignupTopBar extends StatelessWidget {
  const SignupTopBar({super.key, required this.onBack, this.title = 'Sign up'});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: context.text.titleMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim rounded progress indicator tracking how far through the field steps
/// (email, username, password, confirm password, phone) the user has moved.
class SignupProgressBar extends StatelessWidget {
  const SignupProgressBar({super.key, required this.progress});

  /// Fraction complete, from 0.0 to 1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0, 1)),
          duration: AppDimens.durationMedium,
          curve: Curves.easeOut,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: context.appColors.cardBorder,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}

/// Shared layout for a single-field sign-up step: an optional banner (used by
/// the phone step to show "Hi @username" with an edit shortcut), a headline,
/// an optional supporting line, and the field itself — all scrollable so it
/// never overflows when the keyboard is open.
class SignupFieldStep extends StatelessWidget {
  const SignupFieldStep({
    super.key,
    required this.formKey,
    required this.headline,
    this.subtitle,
    required this.field,
    this.banner,
  });

  final GlobalKey<FormState> formKey;
  final String headline;
  final String? subtitle;
  final Widget field;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.space24,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (banner != null) ...[banner!, const Gap(AppDimens.space20)],
            Text(
              headline,
              style: context.text.headlineMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const Gap(AppDimens.space10),
              Text(
                subtitle!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.appColors.mutedText,
                ),
              ),
            ],
            const Gap(AppDimens.space24),
            field,
          ],
        ),
      ),
    );
  }
}

/// Persistent bottom action area (progress bar + primary continue button,
/// with an optional secondary skip action) that stays fixed while the step
/// content behind it slides, and rises above the keyboard when it opens.
class SignupBottomBar extends StatelessWidget {
  const SignupBottomBar({
    super.key,
    this.progress,
    required this.onContinue,
    this.continueLabel = AppStrings.continueLabel,
    this.onSkip,
    this.isLoading = false,
  });

  final double? progress;
  final VoidCallback? onContinue;
  final String continueLabel;
  final VoidCallback? onSkip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding,
          AppDimens.space12,
          AppDimens.screenPadding,
          AppDimens.space20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress != null) ...[
              SignupProgressBar(progress: progress!),
              const Gap(AppDimens.space16),
            ],
            SizedBox(
              height: AppDimens.buttonHeight,
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : onContinue,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(continueLabel),
              ),
            ),
            if (onSkip != null) ...[
              const Gap(AppDimens.space8),
              TextButton(
                onPressed: isLoading ? null : onSkip,
                child: const Text('Skip for now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
