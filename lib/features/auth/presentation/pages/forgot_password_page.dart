import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/common/common.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:snapconnect/core/utils/validators.dart';
import 'package:snapconnect/features/auth/presentation/BloC/password_reset_cubit.dart';
import 'package:snapconnect/navigation/route_paths.dart';

/// Email → OTP → new-password reset flow.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PasswordResetCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.screenBackground,
      appBar: AppBar(
        title: const Text('Reset password'),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) {
          AppSnackBar.showError(context, state.error!);
          context.read<PasswordResetCubit>().clearError();
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: switch (state.step) {
                PasswordResetStep.enterEmail => _EmailStep(state: state),
                PasswordResetStep.enterOtp => _OtpStep(state: state),
                PasswordResetStep.enterNewPassword =>
                  _NewPasswordStep(state: state),
                PasswordResetStep.done => const _DoneStep(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        Text(
          subtitle,
          style: context.text.bodyMedium
              ?.copyWith(color: context.appColors.mutedText),
        ),
        const Gap(24),
      ],
    );
  }
}

class _EmailStep extends StatefulWidget {
  const _EmailStep({required this.state});

  final PasswordResetState state;

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.state.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<PasswordResetCubit>().sendCode(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = widget.state.isSubmitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Forgot your password?',
            subtitle:
                'Enter the email on your account and we will send you a 6-digit code.',
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.validateEmail,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
            ),
          ),
          const Gap(24),
          FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const _ButtonSpinner()
                : const Text('Send code'),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({required this.state});

  final PasswordResetState state;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<PasswordResetCubit>().verifyCode(_otpController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = widget.state.isSubmitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Enter the code',
            subtitle:
                'If ${widget.state.email} is registered, a 6-digit code is on '
                'its way. It expires in 10 minutes.',
          ),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            textAlign: TextAlign.center,
            validator: (value) => (value ?? '').trim().length == 6
                ? null
                : 'Enter the 6-digit code',
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Code',
              counterText: '',
            ),
          ),
          const Gap(24),
          FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child:
                isSubmitting ? const _ButtonSpinner() : const Text('Verify code'),
          ),
          const Gap(12),
          TextButton(
            onPressed: isSubmitting
                ? null
                : () => context.read<PasswordResetCubit>().restart(),
            child: const Text('Use a different email'),
          ),
        ],
      ),
    );
  }
}

class _NewPasswordStep extends StatefulWidget {
  const _NewPasswordStep({required this.state});

  final PasswordResetState state;

  @override
  State<_NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<_NewPasswordStep> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<PasswordResetCubit>().submitNewPassword(
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = widget.state.isSubmitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Choose a new password',
            subtitle: 'Pick something you have not used before.',
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            validator: Validators.validateNewPassword,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const Gap(14),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            validator: (value) => value == _passwordController.text
                ? null
                : 'Passwords do not match',
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const Gap(24),
          FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const _ButtonSpinner()
                : const Text('Update password'),
          ),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline,
            size: 64, color: context.appColors.success),
        const Gap(16),
        const _StepHeader(
          title: 'Password updated',
          subtitle: 'You can now sign in with your new password.',
        ),
        FilledButton(
          onPressed: () => context.go(RoutePaths.login),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
