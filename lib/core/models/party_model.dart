/// Party model used for event-based shared albums.
class PartyModel {
  const PartyModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.joinCode,
    required this.albumId,
    required this.isActive,
    required this.createdAt,
    required this.memberCount,
    this.description,
    this.expiresAt,
  });

  final String id;
  final String name;
  final String? description;
  final String hostId;
  final String hostName;
  final String joinCode;
  final String albumId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int memberCount;

  /// Creates a party model from Supabase response data.
  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Untitled Party').toString(),
      description: json['description']?.toString(),
      hostId: (json['host_id'] ?? '').toString(),
      hostName: (json['host_name'] ?? 'Host').toString(),
      joinCode: (json['join_code'] ?? '').toString(),
      albumId: (json['album_id'] ?? '').toString(),
      isActive: json['is_active'] == null ? true : json['is_active'] as bool,
      createdAt: _parseDate(json['created_at']),
      expiresAt: json['expires_at'] == null
          ? null
          : _parseDate(json['expires_at']),
      memberCount: _parseCount(json['member_count']),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'host_id': hostId,
      'host_name': hostName,
      'join_code': joinCode,
      'album_id': albumId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'member_count': memberCount,
    };
  }

  /// Creates a copy with selective field updates.
  PartyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? hostId,
    String? hostName,
    String? joinCode,
    String? albumId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? memberCount,
  }) {
    return PartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      joinCode: joinCode ?? this.joinCode,
      albumId: albumId ?? this.albumId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static int _parseCount(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? 0;
  }
}
