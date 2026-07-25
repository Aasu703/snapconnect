import 'package:flutter/material.dart';
import 'package:snapconnect/common/constants/app_dimens.dart';
import 'package:snapconnect/common/theme/context_extensions.dart';

/// Minimal custom bottom navigation: five equal-weight icon+label tabs.
///
/// Colors are theme-aware so the bar reads correctly in dark mode.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
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
    final accent = context.colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.navBarHeight,
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
                    color: accent,
                    backgroundColor: context.colors.outlineVariant,
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
                    icon: Icons.event_outlined,
                    activeIcon: Icons.event,
                    label: 'Events',
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.celebration_outlined,
                    activeIcon: Icons.celebration,
                    label: 'Parties',
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.add_circle_outline_rounded,
                    activeIcon: Icons.add_circle_rounded,
                    label: 'Upload',
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
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
    final color =
        isActive ? context.colors.primary : context.colors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: SizedBox(
          height: AppDimens.navItemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppDimens.durationFast,
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey<bool>(isActive),
                  color: color,
                  size: AppDimens.iconMd,
                ),
              ),
              const SizedBox(height: AppDimens.space2),
              Text(
                label,
                style: context.text.bodySmall?.copyWith(
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
