import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/core/utils/validators.dart';

/// First-launch onboarding flow for creating a local identity.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Validates inputs and saves identity.
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
      context.go('/');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4D96FF), Color(0xFF6BCB77)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child:
                      Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Gap(16),
                              Text(
                                'Welcome to SnapConnect',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const Gap(8),
                              Text(
                                'Create your identity to upload photos, react, and join parties.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Gap(20),
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
                              const Gap(20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Get Started'),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0, duration: 300.ms),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
