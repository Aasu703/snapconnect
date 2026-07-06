import 'package:equatable/equatable.dart';

/// Pure domain entity for an event (maps to the `parties` table).
/// Zero imports from Flutter, Supabase, or external SDKs.
class EventEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String hostId;
  final String hostName;
  final String joinCode;
  final DateTime? eventDate;
  final String? location;
  final String? coverImageUrl;
  final bool isActive;
  final DateTime createdAt;

  const EventEntity({
    required this.id,
    required this.name,
    this.description,
    required this.hostId,
    required this.hostName,
    required this.joinCode,
    this.eventDate,
    this.location,
    this.coverImageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        hostId,
        hostName,
        joinCode,
        eventDate,
        location,
        coverImageUrl,
        isActive,
        createdAt,
      ];
}
