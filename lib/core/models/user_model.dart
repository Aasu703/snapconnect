/// App user identity persisted locally and optionally in Supabase.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.createdAt,
    this.email,
  });

  final String id;
  final String name;
  final String? email;
  final String avatarColor;
  final DateTime createdAt;

  /// Creates a model from map payloads returned by Supabase.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Guest').toString(),
      email: json['email']?.toString(),
      avatarColor: (json['avatar_color'] ?? '#FF4D96FF').toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Converts model into serializable payload for persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_color': avatarColor,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with partial updates.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarColor,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
