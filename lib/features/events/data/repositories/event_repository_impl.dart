import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';
import 'package:snapconnect/features/events/data/models/event_model.dart';
import 'package:snapconnect/features/events/domain/entities/event_entity.dart';
import 'package:snapconnect/features/events/domain/repositories/event_repository.dart';

/// Concrete Supabase-backed implementation of [IEventRepository].
/// Uses the existing `parties` table to store events.
class EventRepositoryImpl implements IEventRepository {
  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    try {
      final response = await ApiClient().post(
        ApiEndpoints.parties,
        data: model.toJson(),
      );
      return EventModel.fromJson(response.data['data']);
    } catch (_) {}
    return event;
  }

  @override
  Future<List<EventEntity>> fetchHostEvents(String hostId) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.hostParties(hostId));
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((r) => EventModel.fromJson(r)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<EventEntity?> fetchEventByJoinCode(String joinCode) async {
    try {
      final response = await ApiClient().get(ApiEndpoints.partyByCode(joinCode));
      if (response.statusCode == 200 && response.data['data'] != null) {
        return EventModel.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    try {
      await ApiClient().put(ApiEndpoints.party(event.id), data: model.toJson());
    } catch (_) {}
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await ApiClient().delete(ApiEndpoints.party(eventId));
    } catch (_) {}
  }

  @override
  Future<Map<String, int>> fetchEventStats(String eventId) async {
    // Basic implementation since we don't have dedicated endpoint
    return {
      'photos': 0,
      'guests': 0,
    };
  }
}
