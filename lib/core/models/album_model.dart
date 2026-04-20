/// Album model describing one photo collection.
class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.photoCount,
    this.coverUrl,
    this.createdBy,
    this.createdByName,
  });

  final String id;
  final String name;
  final String? coverUrl;
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final int photoCount;

  /// Creates an album model from Supabase response data.
  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Untitled Album').toString(),
      coverUrl: json['cover_url']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdByName: json['created_by_name']?.toString(),
      createdAt: _parseDate(json['created_at']),
      photoCount: _parseCount(json['photo_count']),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover_url': coverUrl,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'photo_count': photoCount,
    };
  }

  /// Creates a copy with selective field updates.
  AlbumModel copyWith({
    String? id,
    String? name,
    String? coverUrl,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    int? photoCount,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      photoCount: photoCount ?? this.photoCount,
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
