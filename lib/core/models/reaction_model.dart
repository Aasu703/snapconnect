/// Reaction model for emoji interactions on photos.
class ReactionModel {
  const ReactionModel({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.userName,
    required this.emoji,
    required this.createdAt,
  });

  final String id;
  final String photoId;
  final String userId;
  final String userName;
  final String emoji;
  final DateTime createdAt;

  /// Creates a reaction model from Supabase response data.
  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: (json['id'] ?? '').toString(),
      photoId: (json['photo_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      userName: (json['user_name'] ?? 'Guest').toString(),
      emoji: (json['emoji'] ?? '').toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'user_name': userName,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
