import 'package:snapconnect/features/events/domain/entities/event_entity.dart';

/// Event data model with JSON serialization for the `parties` Supabase table.
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.name,
    super.description,
    required super.hostId,
    required super.hostName,
    required super.joinCode,
    super.eventDate,
    super.location,
    super.coverImageUrl,
    super.isActive,
    required super.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      hostId: (json['host_id'] ?? '').toString(),
      hostName: (json['host_name'] ?? 'Host').toString(),
      joinCode: (json['join_code'] ?? '').toString(),
      eventDate: json['event_date'] != null
          ? DateTime.tryParse(json['event_date'].toString())
          : null,
      location: json['location']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // dynamic because the values can be of different types (String, bool, DateTime, etc.)
    // why do we use  map ?
    // to convert the model to a format that can be stored in the database or sent over the network.
    // beacuse map helps to convert the model to a JSON format that can be easily stored in the database or sent over the network.
    // It allows us to represent the model as a key-value pair, which is a common format for data storage and transmission.
    // By using a map, we can easily serialize and deserialize the model when interacting with APIs or databases.
    return {
      'id': id,
      'name': name,
      'description': description,
      'host_id': hostId,
      'host_name': hostName,
      'join_code': joinCode,
      'event_date': eventDate?.toIso8601String(),
      'location': location,
      'cover_image_url': coverImageUrl,
      'is_active': isActive,
    };
  }

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      hostId: entity.hostId,
      hostName: entity.hostName,
      joinCode: entity.joinCode,
      eventDate: entity.eventDate,
      location: entity.location,
      coverImageUrl: entity.coverImageUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
