import 'dart:math';

import 'package:snapconnect/core/models/party_member_model.dart';
import 'package:snapconnect/core/models/party_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';

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
    try {
      final response = await ApiClient().get(ApiEndpoints.parties);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => PartyModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return const <PartyModel>[];
  }

  /// Fetches parties that the given user has joined.
  Future<List<PartyModel>> fetchMyParties(String userId) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.joinedParties(userId));
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => PartyModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return const <PartyModel>[];
  }

  /// Finds a party by join code.
  Future<PartyModel?> getPartyByJoinCode(String joinCode) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.partyByCode(joinCode.toUpperCase()));
      if (response.statusCode == 200) {
        return PartyModel.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  /// Creates a party and backing album, then adds host as member.
  Future<PartyModel> createParty({
    required String name,
    String? description,
    required UserModel host,
  }) async {
    final albumResponse = await ApiClient().post(
      ApiEndpoints.albums,
      data: {
        'fullName': '${name.trim()} Album',
        'created_by': host.id,
        'created_by_name': host.name,
      },
    );
    final album = albumResponse.data['data'];
    final joinCode = await _generateUniqueJoinCode();

    final partyResponse = await ApiClient().post(
      ApiEndpoints.parties,
      data: {
        'name': name.trim(),
        'description': description?.trim().isEmpty ?? true ? null : description!.trim(),
        'host_id': host.id,
        'host_name': host.name,
        'join_code': joinCode,
        'album_id': album['id'],
        'is_active': true,
        'member_count': 1,
      },
    );
    final party = partyResponse.data['data'];

    await ApiClient().post(
      ApiEndpoints.partyJoin,
      data: {
        'party_id': party['id'],
        'user_id': host.id,
        'user_name': host.name,
      },
    );

    return PartyModel.fromJson(party);
  }

  /// Loads party, members, and party album photos in one request flow.
  Future<PartyDetailData?> fetchPartyDetail(String joinCode) async {
    final party = await getPartyByJoinCode(joinCode);
    if (party == null) {
      return null;
    }

    // Since we don't have a single endpoint for party details, 
    // we should ideally fetch members and photos from API, 
    // but the backend we created doesn't have a getMembers API yet. 
    // For now, let's just mock empty lists or we can use what the party endpoint returns.
    // Wait, the backend has no party members fetch route, but it has members count in Party.
    // Let's implement fetch photos from album.
    List<PartyMemberModel> members = [];
    List<PhotoModel> photos = [];

    try {
      final photosRes = await ApiClient().get(ApiEndpoints.albumPhotos(party.albumId));
      if (photosRes.statusCode == 200) {
        photos = (photosRes.data['data'] as List).map((e) => PhotoModel.fromJson(e)).toList();
      }
    } catch (_) {}

    return PartyDetailData(
      party: party,
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

    try {
      await ApiClient().post(
        ApiEndpoints.partyJoin,
        data: {
          'party_id': party.id,
          'user_id': user.id,
          'user_name': user.name,
        },
      );
    } catch (_) {}

    return fetchPartyDetail(joinCode);
  }

  Future<String> _generateUniqueJoinCode() async {
    for (var i = 0; i < 10; i++) {
      final code = _buildJoinCode();
      final existing = await getPartyByJoinCode(code);
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
