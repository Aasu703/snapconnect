import 'package:flutter/material.dart';
import 'package:snapconnect/core/constants/app_colors.dart';

/// Minimal custom bottom navigation with a distinct upload action.
class AppNavbar extends StatelessWidget {
  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.uploadInProgress = false,
    this.uploadProgress,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool uploadInProgress;
  final double? uploadProgress;

  @override
  Widget build(BuildContext context) {
    final progress = uploadProgress?.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Stack(
            children: [
              if (uploadInProgress)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: AppColors.border,
                  ),
                ),
              Row(
                children: [
                  _NavItem(
                    icon: Icons.photo_album_outlined,
                    activeIcon: Icons.photo_album,
                    label: 'Albums',
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.celebration_outlined,
                    activeIcon: Icons.celebration,
                    label: 'Parties',
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () => onTap(2),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: 58,
                          height: 48,
                          transform: Matrix4.translationValues(
                            0,
                            currentIndex == 2 ? -2 : 0,
                            0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          // Laws of UX: Von Restorff Effect + Fitts's Law.
                          child: const Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final color = isActive
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey<bool>(isActive),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
