import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/models/reaction_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/core/services/supabase_service.dart';
import 'package:snapconnect/features/albums/albums_controller.dart';
import 'package:snapconnect/features/onboarding/onboarding_controller.dart';
import 'package:snapconnect/features/party/party_controller.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';

/// Session notifier that persists user identity updates.
class SessionNotifier extends StateNotifier<UserModel?> {
  SessionNotifier() : super(SessionService.instance.getUser());

  /// Stores a logged-in identity.
  Future<void> setUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    state = user;
  }

  /// Updates current identity in memory and storage.
  Future<void> updateUser(UserModel user) async {
    await SessionService.instance.saveUser(user);
    state = user;
  }

  /// Clears current identity.
  Future<void> clear() async {
    await SessionService.instance.clearUser();
    state = null;
  }
}

/// Theme notifier that persists dark mode preference.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier()
      : super(SessionService.instance.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  /// Toggles light and dark mode and persists preference.
  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    await SessionService.instance.setDarkMode(next == ThemeMode.dark);
    state = next;
  }
}

/// Upload notifier that tracks selected files and upload progress.
class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._photosController) : super(const UploadState());

  final PhotosController _photosController;

  /// Picks photos from gallery or desktop picker.
  Future<void> pickPhotos() async {
    final files = await _photosController.pickMultiplePhotos();
    if (files.isEmpty) {
      return;
    }

    final merged = <UploadItem>[...state.items, ...files.map((file) => UploadItem(file: file))];
    final validation = await _photosController.validateFiles(merged.map((item) => item.file).toList());
    if (validation != null) {
      state = state.copyWith(error: validation);
      return;
    }

    state = state.copyWith(
      items: merged,
      totalCount: merged.length,
      error: null,
    );
  }

  /// Captures one photo from camera and appends it to selection.
  Future<void> capturePhoto() async {
    final file = await _photosController.capturePhoto();
    if (file == null) {
      return;
    }

    final merged = <UploadItem>[...state.items, UploadItem(file: file)];
    final validation = await _photosController.validateFiles(merged.map((item) => item.file).toList());
    if (validation != null) {
      state = state.copyWith(error: validation);
      return;
    }

    state = state.copyWith(items: merged, totalCount: merged.length, error: null);
  }

  /// Removes one selected item.
  void removeAt(int index) {
    final items = [...state.items]..removeAt(index);
    state = state.copyWith(items: items, totalCount: items.length);
  }

  /// Retries one failed upload item.
  Future<void> retryItem({
    required int index,
    required String albumId,
    required UserModel user,
    String? title,
  }) async {
    if (index < 0 || index >= state.items.length) {
      return;
    }

    final items = [...state.items];
    items[index] = items[index].copyWith(status: UploadItemStatus.pending, error: null);
    state = state.copyWith(items: items, error: null);

    await uploadAll(albumId: albumId, user: user, title: title);
  }

  /// Uploads all selected items sequentially.
  Future<void> uploadAll({
    required String albumId,
    required UserModel user,
    String? title,
  }) async {
    if (state.items.isEmpty || state.isUploading) {
      return;
    }

    state = state.copyWith(isUploading: true, error: null);

    final nextState = await _photosController.uploadSequentially(
      items: state.items,
      albumId: albumId,
      user: user,
      title: title,
    );

    state = nextState;
  }

  /// Clears all selected files and resets upload state.
  void reset() {
    state = const UploadState();
  }
}

/// Reactions state for one photo.
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

  /// Returns a copy with selective updates.
  ReactionState copyWith({
    Map<String, int>? counts,
    String? currentEmoji,
    Map<String, String>? tooltipByEmoji,
    bool? isLoading,
  }) {
    return ReactionState(
      counts: counts ?? this.counts,
      currentEmoji: currentEmoji,
      tooltipByEmoji: tooltipByEmoji ?? this.tooltipByEmoji,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Manages loading and toggling reactions for one photo ID.
class ReactionsNotifier extends StateNotifier<ReactionState> {
  ReactionsNotifier({required this.photoId, required this.ref}) : super(const ReactionState()) {
    unawaited(load());
  }

  final String photoId;
  final Ref ref;

  /// Loads grouped reaction counts and current user selection.
  Future<void> load() async {
    if (!SupabaseService.isInitialized) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final rows = await SupabaseService.client
        .from('reactions')
        .select()
        .eq('photo_id', photoId)
        .order('created_at', ascending: true);

    final reactions = (rows as List<dynamic>)
        .map((row) => ReactionModel.fromJson(row as Map<String, dynamic>))
        .toList();

    final counts = <String, int>{};
    final namesByEmoji = <String, List<String>>{};
    String? current;
    final user = ref.read(sessionProvider);

    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
      namesByEmoji.putIfAbsent(reaction.emoji, () => <String>[]).add(reaction.userName);
      if (user != null && reaction.userId == user.id) {
        current = reaction.emoji;
      }
    }

    final tooltips = <String, String>{
      for (final entry in namesByEmoji.entries) entry.key: _buildTooltip(entry.value),
    };

    state = ReactionState(
      counts: counts,
      currentEmoji: current,
      tooltipByEmoji: tooltips,
      isLoading: false,
    );
  }

  /// Optimistically toggles reaction and syncs with Supabase.
  Future<void> toggle(String emoji) async {
    final user = ref.read(sessionProvider);
    if (user == null || !SupabaseService.isInitialized) {
      return;
    }

    final previous = state;
    final current = state.currentEmoji;
    final nextCounts = <String, int>{...state.counts};

    if (current == emoji) {
      final count = (nextCounts[emoji] ?? 1) - 1;
      if (count <= 0) {
        nextCounts.remove(emoji);
      } else {
        nextCounts[emoji] = count;
      }
      state = state.copyWith(counts: nextCounts, currentEmoji: null);
    } else {
      if (current != null) {
        final oldCount = (nextCounts[current] ?? 1) - 1;
        if (oldCount <= 0) {
          nextCounts.remove(current);
        } else {
          nextCounts[current] = oldCount;
        }
      }
      nextCounts[emoji] = (nextCounts[emoji] ?? 0) + 1;
      state = state.copyWith(counts: nextCounts, currentEmoji: emoji);
    }

    try {
      final existing = await SupabaseService.client
          .from('reactions')
          .select()
          .eq('photo_id', photoId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null && existing['emoji'] == emoji) {
        await SupabaseService.client.from('reactions').delete().eq('id', existing['id']);
      } else if (existing != null) {
        await SupabaseService.client
            .from('reactions')
            .update({'emoji': emoji})
            .eq('id', existing['id']);
      } else {
        await SupabaseService.client.from('reactions').insert({
          'photo_id': photoId,
          'user_id': user.id,
          'user_name': user.name,
          'emoji': emoji,
        });
      }

      await load();
    } catch (_) {
      state = previous;
    }
  }

  String _buildTooltip(List<String> names) {
    if (names.isEmpty) {
      return 'No reactions yet';
    }
    if (names.length == 1) {
      return names.first;
    }
    if (names.length == 2) {
      return '${names[0]} and ${names[1]}';
    }
    return '${names[0]}, ${names[1]} and ${names.length - 2} others';
  }
}

/// Session provider for current identity.
final sessionProvider = StateNotifierProvider<SessionNotifier, UserModel?>(
  (ref) => SessionNotifier(),
);

/// Theme provider for app-level light/dark mode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Onboarding controller provider.
final onboardingControllerProvider = Provider<OnboardingController>(
  (ref) => OnboardingController(),
);

/// Albums controller provider.
final albumsControllerProvider = Provider<AlbumsController>(
  (ref) => AlbumsController(),
);

/// Photos controller provider.
final photosControllerProvider = Provider<PhotosController>(
  (ref) => PhotosController(),
);

/// Party controller provider.
final partyControllerProvider = Provider<PartyController>(
  (ref) => PartyController(),
);

/// Profile controller provider.
final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(),
);

/// List provider for all albums.
final albumsProvider = FutureProvider<List<AlbumModel>>(
  (ref) => ref.watch(albumsControllerProvider).fetchAlbums(),
);

/// Details provider for one album photo list.
final albumDetailProvider = FutureProvider.family<List<PhotoModel>, String>(
  (ref, albumId) => ref.watch(albumsControllerProvider).fetchAlbumPhotos(albumId),
);

/// Upload workflow state provider.
final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref.watch(photosControllerProvider)),
);

/// List provider for all active parties.
final partiesProvider = FutureProvider<List<PartyModel>>(
  (ref) => ref.watch(partyControllerProvider).fetchAllParties(),
);

/// List provider for parties joined by current user.
final myPartiesProvider = FutureProvider<List<PartyModel>>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) {
    return Future.value(const <PartyModel>[]);
  }
  return ref.watch(partyControllerProvider).fetchMyParties(user.id);
});

/// Detail provider for one party identified by join code.
final partyDetailProvider = FutureProvider.family<PartyDetailData?, String>(
  (ref, joinCode) => ref.watch(partyControllerProvider).fetchPartyDetail(joinCode),
);

/// Reactions provider for one photo.
final reactionsProvider = StateNotifierProvider.family<ReactionsNotifier, ReactionState, String>(
  (ref, photoId) => ReactionsNotifier(photoId: photoId, ref: ref),
);

/// Profile stats provider for current user.
final profileProvider = FutureProvider<ProfileStats>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) {
    return Future.value(
      const ProfileStats(photosUploaded: 0, albumsCreated: 0, partiesJoined: 0),
    );
  }
  return ref.watch(profileControllerProvider).fetchStats(user.id);
});
