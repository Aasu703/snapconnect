import 'package:flutter/material.dart';
import 'package:snapconnect/common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/features/onboarding/onboarding_controller.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/core/di/injection_container.dart';

/// Compact identity form shown before protected actions.
class IdentityBottomSheet extends StatefulWidget {
  const IdentityBottomSheet({
    super.key,
    this.title = 'Before you continue',
    this.subtitle = 'Tell us your name to personalize uploads and reactions.',
  });

  final String title;
  final String subtitle;

  /// Opens the bottom sheet and returns created/restored user.
  static Future<UserModel?> show(
    BuildContext context, {
    String title = 'Before you continue',
    String subtitle = 'Tell us your name to personalize uploads and reactions.',
  }) {
    return showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return IdentityBottomSheet(title: title, subtitle: subtitle);
      },
    );
  }

  @override
  State<IdentityBottomSheet> createState() => _IdentityBottomSheetState();
}

class _IdentityBottomSheetState extends State<IdentityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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

  /// Validates and stores user identity.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = sl<OnboardingController>();
      final user = await controller.createOrRestoreUser(
        name: _nameController.text,
        email: _emailController.text,
      );
      if (!mounted) return;
      await context.read<SessionCubit>().setUser(user);

      if (!mounted) return;
      Navigator.of(context).pop(user);
    } catch (_) {
      if (!mounted) return;

      AppSnackBar.showError(
        context,
        'Could not save identity. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: insets.bottom),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(6),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Alex Johnson',
                    ),
                    validator: Validators.validateName,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      hintText: 'alex@example.com',
                    ),
                    validator: Validators.validateOptionalEmail,
                  ),
                  const Gap(18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
