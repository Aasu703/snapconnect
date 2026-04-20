import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/session_service.dart';
import 'package:snapconnect/core/services/supabase_service.dart';
import 'package:snapconnect/core/utils/avatar_helper.dart';
import 'package:uuid/uuid.dart';

/// Handles first-time identity setup and session persistence.
class OnboardingController {
  OnboardingController({SessionService? sessionService, Uuid? uuid})
    : _sessionService = sessionService ?? SessionService.instance,
      _uuid = uuid ?? const Uuid();

  final SessionService _sessionService;
  final Uuid _uuid;

  /// Creates or restores an identity, then persists it locally.
  Future<UserModel> createOrRestoreUser({
    required String name,
    String? email,
  }) async {
    final displayName = name.trim();
    final normalizedEmail = email?.trim().toLowerCase();
    final colorSeed = (normalizedEmail?.isNotEmpty ?? false)
        ? normalizedEmail!
        : displayName;

    if (SupabaseService.isInitialized &&
        (normalizedEmail?.isNotEmpty ?? false)) {
      final client = SupabaseService.client;

      try {
        final existing = await client
            .from('users')
            .select()
            .eq('email', normalizedEmail!)
            .maybeSingle();

        if (existing != null) {
          final user = UserModel.fromJson(existing);
          await _sessionService.saveUser(user);
          return user;
        }

        final newUserPayload = {
          'id': _uuid.v4(),
          'name': displayName,
          'email': normalizedEmail,
          'avatar_color': AvatarHelper.colorHexFromSeed(colorSeed),
        };

        final inserted = await client
            .from('users')
            .insert(newUserPayload)
            .select()
            .single();

        final user = UserModel.fromJson(inserted);
        await _sessionService.saveUser(user);
        return user;
      } catch (_) {
        // Falls through to local-only session fallback.
      }
    }

    final fallbackUser = UserModel(
      id: _uuid.v4(),
      name: displayName,
      email: normalizedEmail,
      avatarColor: AvatarHelper.colorHexFromSeed(colorSeed),
      createdAt: DateTime.now(),
    );

    await _sessionService.saveUser(fallbackUser);
    return fallbackUser;
  }

  /// Marks onboarding as completed without forcing an identity save.
  Future<void> markCompleted() {
    return _sessionService.setOnboardingCompleted(true);
  }
}
