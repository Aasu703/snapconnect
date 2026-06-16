import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/providers/controllers_provider.dart';
import 'package:snapconnect/core/providers/session_provider.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';

final profileProvider = FutureProvider<ProfileStats>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) {
    return Future.value(
      const ProfileStats(photosUploaded: 0, albumsCreated: 0, partiesJoined: 0),
    );
  }
  return ref.watch(profileControllerProvider).fetchStats(user.id);
});
