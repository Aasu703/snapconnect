/// Party member model for participants in a shared event.
class PartyMemberModel {
  const PartyMemberModel({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.userName,
    required this.joinedAt,
  });

  final String id;
  final String partyId;
  final String userId;
  final String userName;
  final DateTime joinedAt;

  /// Creates a party member model from Supabase response data.
  factory PartyMemberModel.fromJson(Map<String, dynamic> json) {
    return PartyMemberModel(
      id: (json['id'] ?? '').toString(),
      partyId: (json['party_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      userName: (json['user_name'] ?? 'Guest').toString(),
      joinedAt: _parseDate(json['joined_at']),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'party_id': partyId,
      'user_id': userId,
      'user_name': userName,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
