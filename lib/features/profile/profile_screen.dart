import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';
import 'package:snapconnect/features/onboarding/onboarding_controller.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/common/common.dart';

/// Profile screen that always renders a visible state.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileScreen mounted');
    final user = context.read<SessionCubit>().state;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final user = context.read<SessionCubit>().state;
    if (user == null) {
      return;
    }

    final controller = TextEditingController(text: user.name);

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.editName),
          content: AppTextField(
            controller: controller,
            autofocus: true,
            validator: Validators.validateName,
            hint: AppStrings.displayNameHint,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );

    if (name == null || Validators.validateName(name) != null) {
      return;
    }

    final updated = await sl<ProfileController>().updateName(user, name);
    if (!mounted) return;
    await context.read<SessionCubit>().updateUser(updated);
    debugPrint('ProfileScreen: updated name to ${updated.name}');
  }

  Future<void> _addEmail() async {
    final user = context.read<SessionCubit>().state;
    if (user == null) {
      return;
    }

    final controller = TextEditingController(text: user.email ?? '');

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.addEmail),
          content: AppTextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            hint: AppStrings.emailHint,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );

    if (email == null || Validators.validateOptionalEmail(email) != null) {
      return;
    }

    final updated = await sl<ProfileController>().addEmail(user, email);
    if (!mounted) return;
    await context.read<SessionCubit>().updateUser(updated);
    debugPrint('ProfileScreen: updated email to ${updated.email}');
  }

  Future<void> _saveIdentity() async {
    final nameError = Validators.validateName(_nameController.text);
    final emailError = Validators.validateOptionalEmail(_emailController.text);

    if (nameError != null || emailError != null) {
      if (!mounted) {
        return;
      }

      final message =
          nameError ?? emailError ?? AppStrings.fixHighlightedFields;
      AppSnackBar.showError(context, message);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await sl<OnboardingController>().createOrRestoreUser(
            name: _nameController.text,
            email: _emailController.text,
          );
      if (!mounted) return;
      await context.read<SessionCubit>().setUser(user);
      debugPrint('ProfileScreen: identity created/restored for ${user.id}');
    } catch (e, stack) {
      debugPrint('ProfileScreen identity error: $e');
      debugPrint('ProfileScreen identity stack: $stack');
      if (mounted) {
        AppSnackBar.showError(context, AppStrings.profileSetupFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _logout() async {
    await context.read<SessionCubit>().clear();
    debugPrint('ProfileScreen: user logged out');
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileScreen build called');
    final user = context.watch<SessionCubit>().state;
    final themeMode = context.watch<ThemeModeCubit>().state;

    if (user == null) {
      return Scaffold(
        backgroundColor: context.appColors.screenBackground,
        appBar: AppBar(title: const Text(AppStrings.profile)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimens.maxFormWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: AppDimens.iconHero,
                    color: context.appColors.accent,
                  ),
                  const Gap(AppDimens.md),
                  Text(
                    AppStrings.setUpProfile,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppDimens.sm),
                  Text(
                    AppStrings.setUpProfileSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.appColors.mutedText),
                  ),
                  const Gap(AppDimens.lg),
                  AppTextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    label: AppStrings.name,
                    hint: 'Alex Johnson',
                  ),
                  const Gap(AppDimens.space12),
                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    label: AppStrings.emailOptional,
                    hint: 'alex@example.com',
                  ),
                  const Gap(AppDimens.space18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _saveIdentity,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: AppDimens.iconSm,
                              height: AppDimens.iconSm,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.saveProfile),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.screenBackground,
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          Center(
            child: Column(
              children: [
                AvatarWidget(
                  name: user.name,
                  colorHex: user.avatarColor,
                  size: 84,
                ),
                const Gap(AppDimens.space12),
                Text(user.name, style: context.text.headlineSmall),
                const Gap(AppDimens.space6),
                Text(
                  user.email ?? AppStrings.noEmailSet,
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const Gap(AppDimens.space18),
          Container(
            padding: const EdgeInsets.all(AppDimens.space14),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Text(
              'Profile is available instantly from local session data.\n'
              'Stats sync can be added separately if needed.',
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurface),
            ),
          ),
          const Gap(AppDimens.space20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text(AppStrings.editName),
            onTap: _editName,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alternate_email),
            title: Text(
              user.email == null ? AppStrings.addEmail : AppStrings.updateEmail,
            ),
            onTap: _addEmail,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => context.read<ThemeModeCubit>().toggle(),
            title: const Text(AppStrings.darkMode),
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Gap(AppDimens.space8),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
