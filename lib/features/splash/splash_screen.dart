import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snapconnect/common/common.dart';
import 'package:snapconnect/core/services/session_service.dart';

/// Premium animated splash screen with SnapConnect branding.
///
/// Checks authentication state and routes accordingly:
/// - Authenticated → Home
/// - Unauthenticated → the sliding welcome/sign-up flow
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startNavigation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startNavigation() async {
    final disableAnimations = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final wait = disableAnimations
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: 2600);

    await Future<void>.delayed(wait);
    if (!mounted || _navigated) return;

    _navigated = true;
    final hasSession = SessionService.instance.getUser() != null;

    if (hasSession) {
      context.go('/');
    } else {
      // Always land on the welcome/sign-up wizard when logged out — fresh
      // install or just-logged-out alike. It has its own "Log in" button
      // for returning users, so this is the single logged-out entry point.
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final dur = disableAnimations ? 0.ms : 600.ms;
    final delayTitle = disableAnimations ? 0.ms : 500.ms;
    final delayTagline = disableAnimations ? 0.ms : 800.ms;
    final delayLoader = disableAnimations ? 0.ms : 1200.ms;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.brandGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // ── Logo ─────────────────────────────────────────────────
              _AnimatedLogo(duration: dur),
              const SizedBox(height: 28),
              // ── App Name ─────────────────────────────────────────────
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: AppColors.primary.withValues(alpha: 0.7),
                child: Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        fontSize: 36,
                      ),
                ),
              )
                  .animate(delay: delayTitle)
                  .fadeIn(duration: dur)
                  .slideY(begin: 0.3, end: 0, duration: dur),
              const SizedBox(height: 12),
              // ── Tagline ──────────────────────────────────────────────
              Text(
                'Capture · Share · Celebrate',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w300,
                    ),
              )
                  .animate(delay: delayTagline)
                  .fadeIn(duration: dur)
                  .slideY(begin: 0.2, end: 0, duration: dur),
              const Spacer(flex: 3),
              // ── Loading Indicator ────────────────────────────────────
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ).animate(delay: delayLoader).fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFFC77DFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        size: 48,
        color: Colors.white,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: duration);
  }
}
