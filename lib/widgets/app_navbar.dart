import 'package:flutter/material.dart';
import 'package:snapconnect/core/constants/app_colors.dart';

/// Persistent bottom navigation with a prominent upload action.
class AppNavbar extends StatelessWidget {
  const AppNavbar({
    super.key,
    required this.location,
    required this.onNavigate,
  });

  final String location;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedPath(location);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Albums',
              selected: selected == '/',
              onTap: () => onNavigate('/'),
            ),
            _NavItem(
              icon: Icons.celebration_rounded,
              label: 'Parties',
              selected: selected == '/party',
              onTap: () => onNavigate('/party'),
            ),
            Expanded(
              child: Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onNavigate('/upload'),
                  child: Ink(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selected == '/profile',
              onTap: () => onNavigate('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  String _selectedPath(String location) {
    if (location.startsWith('/party')) {
      return '/party';
    }
    if (location.startsWith('/profile')) {
      return '/profile';
    }
    if (location.startsWith('/upload')) {
      return '/upload';
    }
    return '/';
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
