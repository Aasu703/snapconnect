import 'package:snapconnect/features/events/domain/entities/event_entity.dart';

/// Abstract contract for event data operations.
abstract class IEventRepository {
  Future<EventEntity> createEvent(EventEntity event);
  Future<List<EventEntity>> fetchHostEvents(String hostId);
  Future<EventEntity?> fetchEventByJoinCode(String joinCode);
  Future<void> updateEvent(EventEntity event);
  Future<void> deleteEvent(String eventId);
  Future<Map<String, int>> fetchEventStats(String eventId);
}
