import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/common/common.dart';
import 'package:snapconnect/core/utils/validators.dart';
import '../BloC/auth_cubit.dart';
import '../BloC/auth_state.dart';
import '../widgets/signup_chrome.dart';
import '../widgets/welcome_collage_background.dart';

/// Sliding, single-field-per-step sign-up flow: welcome → email → name →
/// password → confirm password → phone (optional). Each step validates
/// itself before the page slides to the next, matching a Pinterest-style
/// step wizard while reusing this app's existing auth BLoC and theme tokens.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum _Step { welcome, email, name, password, confirmPassword, phone }

class _RegisterPageState extends State<RegisterPage> {
  static const _steps = _Step.values;
  static const _fieldStepCount = 5; // field steps, excludes welcome

  final _pageController = PageController();
  int _index = 0;

  final _emailKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _confirmPasswordKey = GlobalKey<FormState>();
  final _phoneKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppDimens.durationSlow,
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() => _goToPage(_index + 1);

  void _goBack() {
    if (_index == 0) {
      context.go('/login');
    } else {
      _goToPage(_index - 1);
    }
  }

  void _validateAndAdvance(GlobalKey<FormState> key) {
    if (key.currentState?.validate() ?? false) {
      _goNext();
    }
  }

  void _validateAndSubmit() {
    if (_phoneKey.currentState?.validate() ?? false) {
      _submit();
    }
  }

  void _skipPhone() {
    _phoneController.clear();
    _submit();
  }

  void _submit() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    context.read<AuthCubit>().register({
      'Firstname': firstName,
      'Lastname': lastName,
      'username': firstName,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      if (phone.isNotEmpty) 'phone': phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final isWelcome = step == _Step.welcome;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            AppSnackBar.showSuccess(context, 'Account created! Please sign in.');
            context.go('/login');
          } else if (state is AuthError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Kept as a permanent slot (rather than conditionally inserted)
              // so the Column's child count never changes — otherwise
              // Flutter re-slots the PageView below on every step transition
              // and remounts it back to page 0.
              isWelcome ? const SizedBox.shrink() : SignupTopBar(onBack: _goBack),
              Expanded(
                child: PageView(
                  key: const PageStorageKey('signup_pageview'),
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _WelcomeStep(
                      onCreateAccount: _goNext,
                      onLogIn: () => context.go('/login'),
                    ),
                    SignupFieldStep(
                      formKey: _emailKey,
                      headline: "What's your email?",
                      subtitle: "We'll use this to keep your account secure.",
                      field: AppTextField(
                        controller: _emailController,
                        hint: 'you@example.com',
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _validateAndAdvance(_emailKey),
                        validator: Validators.validateEmail,
                      ),
                    ),
                    SignupFieldStep(
                      formKey: _nameKey,
                      headline: "What's your name?",
                      subtitle:
                          "This is how friends find you. You can change it later.",
                      field: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _firstNameController,
                            hint: 'Enter your first name',
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            validator: Validators.validateName,
                          ),
                          const Gap(AppDimens.space16),
                          AppTextField(
                            controller: _lastNameController,
                            hint: 'Enter your last name',
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _validateAndAdvance(_nameKey),
                            validator: Validators.validateName,
                          ),
                        ],
                      ),
                    ),
                    SignupFieldStep(
                      formKey: _passwordKey,
                      headline: 'Create a password',
                      subtitle:
                          'Use at least 6 characters. Make it something only you would guess.',
                      field: AppTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        autofocus: true,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _validateAndAdvance(_passwordKey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.appColors.mutedText,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                      ),
                    ),
                    SignupFieldStep(
                      formKey: _confirmPasswordKey,
                      headline: 'Confirm your password',
                      subtitle: "Enter it once more so we know it's right.",
                      field: AppTextField(
                        controller: _confirmPasswordController,
                        hint: '••••••••',
                        autofocus: true,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _validateAndAdvance(_confirmPasswordKey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.appColors.mutedText,
                            size: 20,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        validator: (v) => Validators.validateConfirmPassword(
                            _passwordController.text, v),
                      ),
                    ),
                    SignupFieldStep(
                      formKey: _phoneKey,
                      banner: _EditableBanner(
                        nameListenable: _firstNameController,
                        onEdit: () => _goToPage(_Step.name.index),
                      ),
                      headline: "What's your phone number?",
                      subtitle:
                          "Optional — helps keep your account secure. It won't be shown on your profile.",
                      field: AppTextField(
                        controller: _phoneController,
                        hint: '+1 234 567 890',
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _validateAndSubmit(),
                        validator: Validators.validateOptionalPhone,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (isWelcome) return const SizedBox.shrink();
                  final isLoading = state is AuthLoading;
                  return SignupBottomBar(
                    progress: _index / _fieldStepCount,
                    isLoading: isLoading,
                    continueLabel: step == _Step.phone
                        ? 'Create Account'
                        : AppStrings.continueLabel,
                    onSkip: step == _Step.phone ? _skipPhone : null,
                    onContinue: switch (step) {
                      _Step.welcome => null,
                      _Step.email => () => _validateAndAdvance(_emailKey),
                      _Step.name => () =>
                          _validateAndAdvance(_nameKey),
                      _Step.password => () =>
                          _validateAndAdvance(_passwordKey),
                      _Step.confirmPassword => () =>
                          _validateAndAdvance(_confirmPasswordKey),
                      _Step.phone => _validateAndSubmit,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows "Hi {name}" with a shortcut back to the name step, mirroring
/// the reference design's editable-name banner on its final step.
class _EditableBanner extends StatelessWidget {
  const _EditableBanner({
    required this.nameListenable,
    required this.onEdit,
  });

  final TextEditingController nameListenable;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: nameListenable,
      builder: (context, _) {
        final name = nameListenable.text.trim();
        return Row(
          children: [
            Text(
              name.isEmpty ? 'Hi there' : 'Hi $name',
              style: context.text.titleMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            const Gap(AppDimens.space8),
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: context.appColors.mutedText,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onCreateAccount, required this.onLogIn});

  final VoidCallback onCreateAccount;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    final collageHeight = MediaQuery.sizeOf(context).height * 0.4;

    return Stack(
      children: [
        WelcomeCollageBackground(height: collageHeight),
        SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
          child: Column(
            children: [
              Gap(collageHeight * 0.78),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 40),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
              const Gap(AppDimens.space24),
              Text(
                'Welcome to ${AppStrings.appName}',
                textAlign: TextAlign.center,
                style: context.text.headlineMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const Gap(AppDimens.space10),
              Text(
                'Capture, share, and celebrate every moment together.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.appColors.mutedText,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const Gap(AppDimens.space40),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onCreateAccount,
                  child: const Text('Sign up'),
                ),
              ),
              const Gap(AppDimens.space12),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: context.appColors.cardBorder),
                  ),
                  onPressed: onLogIn,
                  child: const Text('Log in'),
                ),
              ),
              const Gap(AppDimens.space32),
              _TermsNotice(),
              const Gap(AppDimens.space24),
            ],
          ),
        ),
      ],
    );
  }
}

/// Static "by continuing you agree..." notice, matching the reference
/// design's terms frame — informational rather than a blocking checkbox.
class _TermsNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = context.text.bodySmall?.copyWith(
      color: context.appColors.mutedText,
    );
    final linkStyle = style?.copyWith(
      color: context.colors.primary,
      fontWeight: FontWeight.w600,
    );

    void showComingSoon() =>
        AppSnackBar.showInfo(context, AppStrings.comingSoon);

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = showComingSoon,
          ),
          const TextSpan(text: ' and acknowledge our '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = showComingSoon,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
