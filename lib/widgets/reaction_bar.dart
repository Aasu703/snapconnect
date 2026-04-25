import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/providers/app_providers.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Emoji reaction row with counts and optimistic updates.
class ReactionBar extends ConsumerWidget {
  const ReactionBar({super.key, required this.photoId});

  final String photoId;

  static const List<String> _emojis = <String>['❤️', '😂', '🔥', '😮', '👏'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactionState = ref.watch(reactionsProvider(photoId));

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _emojis.map((emoji) {
          final count = reactionState.counts[emoji] ?? 0;
          final isSelected = reactionState.currentEmoji == emoji;
          final tooltip =
              reactionState.tooltipByEmoji[emoji] ?? 'No reactions yet';

          return Tooltip(
            message: tooltip,
            triggerMode: TooltipTriggerMode.longPress,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () async {
                final user = ref.read(sessionProvider);
                if (user == null) {
                  await IdentityBottomSheet.show(
                    context,
                    title: 'Add your identity',
                    subtitle:
                        'React as yourself so friends can see who responded.',
                  );
                }

                if (ref.read(sessionProvider) == null) {
                  return;
                }

                await ref
                    .read(reactionsProvider(photoId).notifier)
                    .toggle(emoji);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child:
                    AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 16)),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '$count',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ],
                          ),
                        )
                        .animate(target: isSelected ? 1 : 0)
                        // Laws of UX: micro feedback improves perceived responsiveness.
                        .scaleXY(begin: 1, end: 1.4, duration: 100.ms)
                        .then()
                        .scaleXY(begin: 1.4, end: 1.0, duration: 100.ms),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
