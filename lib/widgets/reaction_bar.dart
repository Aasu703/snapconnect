import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/blocs/reactions_cubit.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';

/// Emoji reaction row with counts and optimistic updates.
///
/// By default creates and owns its own [ReactionsCubit]. Pass [cubit] to
/// instead share an ancestor-provided instance (e.g. so a long-press
/// reaction picker on the photo itself stays in sync with this bar).
class ReactionBar extends StatelessWidget {
  const ReactionBar({super.key, required this.photoId, this.cubit});

  final String photoId;
  final ReactionsCubit? cubit;

  static const List<String> emojis = <String>['❤️', '😂', '🔥', '😮', '👏'];

  @override
  Widget build(BuildContext context) {
    final providedCubit = cubit;
    if (providedCubit != null) {
      return BlocProvider.value(
        value: providedCubit,
        child: const _ReactionBarContent(emojis: emojis),
      );
    }

    return BlocProvider(
      create: (_) => ReactionsCubit(photoId: photoId)..load(context.read<SessionCubit>().state),
      child: const _ReactionBarContent(emojis: emojis),
    );
  }
}

class _ReactionBarContent extends StatelessWidget {
  const _ReactionBarContent({required this.emojis});

  final List<String> emojis;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReactionsCubit, ReactionState>(
      builder: (context, reactionState) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emojis.map((emoji) {
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
                    final user = context.read<SessionCubit>().state;
                    if (user == null) {
                      await IdentityBottomSheet.show(
                        context,
                        title: 'Add your identity',
                        subtitle:
                            'React as yourself so friends can see who responded.',
                      );
                    }

                    if (!context.mounted) return;
                    final updatedUser = context.read<SessionCubit>().state;
                    if (updatedUser == null) {
                      return;
                    }

                    await context.read<ReactionsCubit>().toggle(emoji, updatedUser);
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
      },
    );
  }
}
