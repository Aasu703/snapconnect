import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/providers/controllers_provider.dart';
import 'package:snapconnect/core/providers/session_provider.dart';
import 'package:snapconnect/features/party/party_controller.dart';

final partiesProvider = FutureProvider<List<PartyModel>>((ref) async {
  try {
    return await ref.watch(partyControllerProvider).fetchAllParties();
  } catch (e, stack) {
    debugPrint('partiesProvider ERROR: $e\n$stack');
    rethrow;
  }
});

final myPartiesProvider = FutureProvider<List<PartyModel>>((ref) {
  final user = ref.watch(sessionProvider);
  if (user == null) return Future.value(const <PartyModel>[]);
  return ref.watch(partyControllerProvider).fetchMyParties(user.id);
});

final partyDetailProvider = FutureProvider.family<PartyDetailData?, String>(
  (ref, joinCode) =>
      ref.watch(partyControllerProvider).fetchPartyDetail(joinCode),
);
