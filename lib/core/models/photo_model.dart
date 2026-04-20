/// Photo record model for one uploaded image.
class PhotoModel {
  const PhotoModel({
    required this.id,
    required this.albumId,
    required this.url,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.createdAt,
    this.title,
  });

  final String id;
  final String albumId;
  final String url;
  final String? title;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime createdAt;

  /// Creates a photo model from Supabase response data.
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: (json['id'] ?? '').toString(),
      albumId: (json['album_id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      title: json['title']?.toString(),
      uploadedBy: (json['uploaded_by'] ?? '').toString(),
      uploadedByName: (json['uploaded_by_name'] ?? 'Guest').toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'album_id': albumId,
      'url': url,
      'title': title,
      'uploaded_by': uploadedBy,
      'uploaded_by_name': uploadedByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with selective field updates.
  PhotoModel copyWith({
    String? id,
    String? albumId,
    String? url,
    String? title,
    String? uploadedBy,
    String? uploadedByName,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      url: url ?? this.url,
      title: title ?? this.title,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
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
