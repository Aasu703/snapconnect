import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/models/reaction_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';

// ── State ──────────────────────────────────────────────────────────────────

class ReactionState {
  const ReactionState({
    this.counts = const <String, int>{},
    this.currentEmoji,
    this.tooltipByEmoji = const <String, String>{},
    this.isLoading = false,
  });

  final Map<String, int> counts;
  final String? currentEmoji;
  final Map<String, String> tooltipByEmoji;
  final bool isLoading;

  static const Object _unset = Object();

  ReactionState copyWith({
    Map<String, int>? counts,
    Object? currentEmoji = _unset,
    Map<String, String>? tooltipByEmoji,
    bool? isLoading,
  }) {
    return ReactionState(
      counts: counts ?? this.counts,
      currentEmoji: identical(currentEmoji, _unset)
          ? this.currentEmoji
          : currentEmoji as String?,
      tooltipByEmoji: tooltipByEmoji ?? this.tooltipByEmoji,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class ReactionsCubit extends Cubit<ReactionState> {
  ReactionsCubit({required this.photoId}) : super(const ReactionState()) {
    sl<AppLogger>().debug('ReactionsCubit initialized for photo $photoId');
  }

  final String photoId;

  Future<void> load(UserModel? user) async {
    emit(state.copyWith(isLoading: true));
    sl<AppLogger>().info('Loading reactions for photo $photoId');

    // Backend doesn't have reactions endpoint yet. We can mock it for now.
    final List<ReactionModel> reactions = [];

    final counts = <String, int>{};
    final namesByEmoji = <String, List<String>>{};
    String? current;

    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
      namesByEmoji
          .putIfAbsent(reaction.emoji, () => <String>[])
          .add(reaction.userName);
      if (user != null && reaction.userId == user.id) {
        current = reaction.emoji;
      }
    }

    emit(ReactionState(
      counts: counts,
      currentEmoji: current,
      tooltipByEmoji: {
        for (final entry in namesByEmoji.entries)
          entry.key: _buildTooltip(entry.value),
      },
      isLoading: false,
    ));
    sl<AppLogger>().good('Reactions loaded for photo $photoId');
  }

  Future<void> toggle(String emoji, UserModel? user) async {
    if (user == null) {
      sl<AppLogger>().warning('Cannot toggle reaction, user is null');
      return;
    }

    sl<AppLogger>().info('Toggling reaction $emoji for photo $photoId');

    final previous = state;
    final current = state.currentEmoji;
    final nextCounts = <String, int>{...state.counts};

    if (current == emoji) {
      final count = (nextCounts[emoji] ?? 1) - 1;
      count <= 0 ? nextCounts.remove(emoji) : nextCounts[emoji] = count;
      emit(state.copyWith(counts: nextCounts, currentEmoji: null));
    } else {
      if (current != null) {
        final oldCount = (nextCounts[current] ?? 1) - 1;
        oldCount <= 0
            ? nextCounts.remove(current)
            : nextCounts[current] = oldCount;
      }
      nextCounts[emoji] = (nextCounts[emoji] ?? 0) + 1;
      emit(state.copyWith(counts: nextCounts, currentEmoji: emoji));
    }

    try {
      // Backend missing reactions toggle API, mock it for now.
      await load(user);
    } catch (e) {
      sl<AppLogger>().error('Error toggling reaction: $e');
      emit(previous);
    }
  }

  String _buildTooltip(List<String> names) {
    if (names.isEmpty) return 'No reactions yet';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names[0]}, ${names[1]} and ${names.length - 2} others';
  }
}
