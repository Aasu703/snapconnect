import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';

/// Compact identity form shown before protected actions.
class IdentityBottomSheet extends ConsumerStatefulWidget {
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
  ConsumerState<IdentityBottomSheet> createState() => _IdentityBottomSheetState();
}

class _IdentityBottomSheetState extends ConsumerState<IdentityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
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
      final controller = ref.read(onboardingControllerProvider);
      final user = await controller.createOrRestoreUser(
        name: _nameController.text,
        email: _emailController.text,
      );
      await ref.read(sessionProvider.notifier).setUser(user);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(user);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save identity. Please try again.')),
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
                  Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                  const Gap(6),
                  Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
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
