import 'dart:math';

import 'package:snapconnect/core/models/party_member_model.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

/// Aggregated payload for party detail UI.
class PartyDetailData {
  const PartyDetailData({
    required this.party,
    required this.members,
    required this.photos,
  });

  final PartyModel party;
  final List<PartyMemberModel> members;
  final List<PhotoModel> photos;
}

/// Handles party creation, joining, and detail loading.
class PartyController {
  static const String _joinChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random _random = Random();

  /// Fetches active parties ordered by newest first.
  Future<List<PartyModel>> fetchAllParties() async {
    if (!SupabaseService.isInitialized) {
      return const <PartyModel>[];
    }

    final rows = await SupabaseService.client
        .from('parties')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => PartyModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Fetches parties that the given user has joined.
  Future<List<PartyModel>> fetchMyParties(String userId) async {
    if (!SupabaseService.isInitialized) {
      return const <PartyModel>[];
    }

    final membershipRows = await SupabaseService.client
        .from('party_members')
        .select('party_id')
        .eq('user_id', userId);

    final partyIds = (membershipRows as List<dynamic>)
        .map((row) => row['party_id']?.toString())
        .whereType<String>()
        .toList();

    if (partyIds.isEmpty) {
      return const <PartyModel>[];
    }

    final rows = await SupabaseService.client
        .from('parties')
        .select()
        .filter('id', 'in', '(${partyIds.map((id) => '"$id"').join(',')})')
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => PartyModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Finds a party by join code.
  Future<PartyModel?> getPartyByJoinCode(String joinCode) async {
    if (!SupabaseService.isInitialized) {
      return null;
    }

    final row = await SupabaseService.client
        .from('parties')
        .select()
        .eq('join_code', joinCode.toUpperCase())
        .eq('is_active', true)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return PartyModel.fromJson(row);
  }

  /// Creates a party and backing album, then adds host as member.
  Future<PartyModel> createParty({
    required String name,
    String? description,
    required UserModel host,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw StateError('Supabase is not initialized.');
    }

    final album = await SupabaseService.client
        .from('albums')
        .insert({
          'name': '${name.trim()} Album',
          'created_by': host.id,
          'created_by_name': host.name,
        })
        .select()
        .single();

    final joinCode = await _generateUniqueJoinCode();

    final party = await SupabaseService.client
        .from('parties')
        .insert({
          'name': name.trim(),
          'description': description?.trim().isEmpty ?? true ? null : description!.trim(),
          'host_id': host.id,
          'host_name': host.name,
          'join_code': joinCode,
          'album_id': album['id'],
          'is_active': true,
          'member_count': 1,
        })
        .select()
        .single();

    await SupabaseService.client.from('party_members').insert({
      'party_id': party['id'],
      'user_id': host.id,
      'user_name': host.name,
    });

    return PartyModel.fromJson(party);
  }

  /// Loads party, members, and party album photos in one request flow.
  Future<PartyDetailData?> fetchPartyDetail(String joinCode) async {
    final party = await getPartyByJoinCode(joinCode);
    if (party == null) {
      return null;
    }

    final membersRows = await SupabaseService.client
        .from('party_members')
        .select()
        .eq('party_id', party.id)
        .order('joined_at', ascending: true);

    final photosRows = await SupabaseService.client
        .from('photos')
        .select()
        .eq('album_id', party.albumId)
        .order('created_at', ascending: false);

    final members = (membersRows as List<dynamic>)
        .map((row) => PartyMemberModel.fromJson(row as Map<String, dynamic>))
        .toList();
    final photos = (photosRows as List<dynamic>)
        .map((row) => PhotoModel.fromJson(row as Map<String, dynamic>))
        .toList();

    return PartyDetailData(
      party: party.copyWith(memberCount: members.length),
      members: members,
      photos: photos,
    );
  }

  /// Joins a user to the party by join code and returns updated detail payload.
  Future<PartyDetailData?> joinParty({
    required String joinCode,
    required UserModel user,
  }) async {
    final party = await getPartyByJoinCode(joinCode);
    if (party == null) {
      return null;
    }

    final existingMember = await SupabaseService.client
        .from('party_members')
        .select()
        .eq('party_id', party.id)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existingMember == null) {
      await SupabaseService.client.from('party_members').insert({
        'party_id': party.id,
        'user_id': user.id,
        'user_name': user.name,
      });

      final membersRows = await SupabaseService.client
          .from('party_members')
          .select('id')
          .eq('party_id', party.id);

      await SupabaseService.client
          .from('parties')
          .update({'member_count': (membersRows as List<dynamic>).length})
          .eq('id', party.id);
    }

    return fetchPartyDetail(joinCode);
  }

  Future<String> _generateUniqueJoinCode() async {
    for (var i = 0; i < 10; i++) {
      final code = _buildJoinCode();
      final existing = await SupabaseService.client
          .from('parties')
          .select('id')
          .eq('join_code', code)
          .maybeSingle();
      if (existing == null) {
        return code;
      }
    }

    return _buildJoinCode();
  }

  String _buildJoinCode() {
    return List.generate(
      6,
      (_) => _joinChars[_random.nextInt(_joinChars.length)],
    ).join();
  }
}
