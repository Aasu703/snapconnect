import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable page template for each onboarding slide.
///
/// Displays a large gradient circle with an icon, floating decorative
/// elements, title, and subtitle text.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.decorIcon1,
    required this.decorIcon2,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final IconData decorIcon1;
  final IconData decorIcon2;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final circleSize = size.width * 0.52;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // ── Illustration Area ──────────────────────────────────────
          SizedBox(
            height: size.height * 0.38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: circleSize + 40,
                  height: circleSize + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gradientColors[0].withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.04, 1.04),
                      duration: 2200.ms,
                      curve: Curves.easeInOut,
                    ),
                // Main gradient circle
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.35),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 64, color: Colors.white),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
                // Floating decoration 1
                Positioned(
                  top: 20,
                  right: 20,
                  child: _FloatingDecor(
                    icon: decorIcon1,
                    color: gradientColors[1],
                    size: 44,
                    delay: 300.ms,
                  ),
                ),
                // Floating decoration 2
                Positioned(
                  bottom: 30,
                  left: 16,
                  child: _FloatingDecor(
                    icon: decorIcon2,
                    color: gradientColors[0],
                    size: 38,
                    delay: 500.ms,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          // ── Text Content ──────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 15,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({
    required this.icon,
    required this.color,
    required this.size,
    required this.delay,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: size * 0.5, color: color.withValues(alpha: 0.8)),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -4, end: 4, duration: 2000.ms, curve: Curves.easeInOut);
  }
}
