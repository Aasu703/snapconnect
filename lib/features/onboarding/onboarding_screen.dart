import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/features/onboarding/presentation/widgets/onboarding_page_widget.dart';

/// Multi-page sliding onboarding intro that sets the tone
/// for hosts and guests before directing to authentication.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingData>[
    _OnboardingData(
      icon: Icons.camera_alt_rounded,
      gradientColors: [Color(0xFF4D96FF), Color(0xFF6BC5F8)],
      title: 'Capture Every Moment',
      subtitle:
          'Take photos at events and share them instantly with everyone present. Never miss a memory again.',
      decorIcon1: Icons.photo_library_rounded,
      decorIcon2: Icons.flash_on_rounded,
    ),
    _OnboardingData(
      icon: Icons.group_rounded,
      gradientColors: [Color(0xFFC77DFF), Color(0xFFFF6FD8)],
      title: 'Share With Your Crew',
      subtitle:
          'Collaborate on live event albums in real-time. Everyone contributes, everyone enjoys.',
      decorIcon1: Icons.share_rounded,
      decorIcon2: Icons.favorite_rounded,
    ),
    _OnboardingData(
      icon: Icons.qr_code_scanner_rounded,
      gradientColors: [Color(0xFF6BCB77), Color(0xFF00C9A7)],
      title: 'Host or Join Events',
      subtitle:
          'Create events with a unique QR code, or scan one to join instantly. It\'s that simple.',
      decorIcon1: Icons.celebration_rounded,
      decorIcon2: Icons.qr_code_rounded,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() => _finishOnboarding();

  Future<void> _finishOnboarding() async {
    await SessionService.instance.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip Button ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 16, top: 12),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // ── Page View ──────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final data = _pages[index];
                    return OnboardingPageWidget(
                      icon: data.icon,
                      gradientColors: data.gradientColors,
                      title: data.title,
                      subtitle: data.subtitle,
                      decorIcon1: data.decorIcon1,
                      decorIcon2: data.decorIcon2,
                    );
                  },
                ),
              ),
              // ── Page Indicators + Action Button ────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.25),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: FilledButton(
                          key: ValueKey(isLast),
                          onPressed: _nextPage,
                          style: FilledButton.styleFrom(
                            backgroundColor: isLast
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.12),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLast ? 'Get Started' : 'Next'),
                              if (isLast) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final IconData decorIcon1;
  final IconData decorIcon2;

  const _OnboardingData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.decorIcon1,
    required this.decorIcon2,
  });
}
