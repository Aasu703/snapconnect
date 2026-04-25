import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
  final _emailFocusNode = FocusNode();

  bool _isSubmitting = false;

  bool get _canContinue =>
      _nameController.text.trim().length >= 2 && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
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
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final visualHeight = keyboardOpen ? 0.24 : 0.40;
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Laws of UX: Aesthetic-Usability Effect with a clear branded first impression.
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOut,
                  height: constraints.maxHeight * visualHeight,
                  width: double.infinity,
                  child: _OnboardingTopVisual(
                    disableAnimations: disableAnimations,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Form(
                          key: _formKey,
                          child:
                              Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'What should we call you?',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Just your name - no account needed',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const Gap(20),
                                      TextFormField(
                                        controller: _nameController,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) => FocusScope.of(
                                          context,
                                        ).requestFocus(_emailFocusNode),
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          hintText: 'Your name',
                                        ),
                                        validator: Validators.validateName,
                                      ),
                                      const Gap(12),
                                      TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) {
                                          if (_canContinue) {
                                            _submit();
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Email (optional)',
                                          hintText: 'your@email.com (optional)',
                                        ),
                                        validator:
                                            Validators.validateOptionalEmail,
                                      ),
                                      const Gap(20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeOut,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: _canContinue
                                                ? const Color(0xFF4D96FF)
                                                : const Color(0xFFD0D5DD),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              onTap: _canContinue
                                                  ? _submit
                                                  : null,
                                              child: Center(
                                                // Laws of UX: Fitts's Law with 56px minimum action target.
                                                child: _isSubmitting
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                    : Text(
                                                        'Continue',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .slideY(
                                    begin: disableAnimations ? 0 : 0.35,
                                    end: 0,
                                    duration: disableAnimations ? 0.ms : 300.ms,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .fade(
                                    duration: disableAnimations ? 0.ms : 260.ms,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingTopVisual extends StatelessWidget {
  const _OnboardingTopVisual({required this.disableAnimations});

  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4D96FF), Color(0xFFC77DFF)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _floatingCard(
            width: 128,
            height: 164,
            color: Colors.white.withValues(alpha: 0.22),
            rotation: -0.24,
            offset: const Offset(-76, 8),
          ),
          _floatingCard(
            width: 142,
            height: 188,
            color: Colors.white.withValues(alpha: 0.92),
            rotation: 0.02,
            offset: const Offset(0, 2),
          ),
          _floatingCard(
            width: 122,
            height: 156,
            color: Colors.white.withValues(alpha: 0.28),
            rotation: 0.20,
            offset: const Offset(78, 16),
          ),
        ],
      ),
    ).animate().fade(duration: disableAnimations ? 0.ms : 260.ms);
  }

  Widget _floatingCard({
    required double width,
    required double height,
    required Color color,
    required double rotation,
    required Offset offset,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
