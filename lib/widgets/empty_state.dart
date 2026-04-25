import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

/// Generic empty-state widget with icon, text, and optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.photo_library_outlined,
    this.emoji,
    this.animateEmoji = true,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? emoji;
  final bool animateEmoji;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final canAnimateEmoji = !disableAnimations && animateEmoji;

    final visual = emoji != null
        ? Text(emoji!, style: textTheme.displayMedium)
        : Icon(
            icon,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.65),
          );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            canAnimateEmoji
                ? visual
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(
                        begin: 0,
                        end: -10,
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                      )
                : visual,
            const Gap(16),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              subtitle,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const Gap(20),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(180, 56),
                  shape: const StadiumBorder(),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
