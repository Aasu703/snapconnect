import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/services/session_service.dart';

/// Animated launch screen shown before onboarding or home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final disableAnimations = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    final wait = disableAnimations
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 2200);

    await Future<void>.delayed(wait);
    if (!mounted) {
      return;
    }

    final hasSession = SessionService.instance.getUser() != null;
    if (hasSession) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final logoDuration = disableAnimations ? 0.ms : 600.ms;
    final titleDelay = disableAnimations ? 0.ms : 400.ms;
    final titleDuration = disableAnimations ? 0.ms : 400.ms;
    final taglineDelay = disableAnimations ? 0.ms : 700.ms;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Laws of UX: Von Restorff Effect with a distinct branded focal point.
            Shimmer.fromColors(
                  baseColor: const Color(0xFF4D96FF),
                  highlightColor: const Color(0xFF8CC0FF),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: logoDuration,
                  curve: Curves.easeOutBack,
                )
                .fade(duration: logoDuration),
            const SizedBox(height: 20),
            Text(
                  'Album',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                )
                .animate(delay: titleDelay)
                .fade(duration: titleDuration)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: titleDuration,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 8),
            Text(
              'Your memories, beautifully',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ).animate(delay: taglineDelay).fade(duration: titleDuration),
          ],
        ),
      ),
    );
  }
}
