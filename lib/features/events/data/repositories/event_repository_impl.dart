import 'package:snapconnect/core/services/supabase_service.dart';
import 'package:snapconnect/features/events/data/models/event_model.dart';
import 'package:snapconnect/features/events/domain/entities/event_entity.dart';
import 'package:snapconnect/features/events/domain/repositories/event_repository.dart';

/// Concrete Supabase-backed implementation of [IEventRepository].
/// Uses the existing `parties` table to store events.
class EventRepositoryImpl implements IEventRepository {
  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    final inserted = await SupabaseService.client
        .from('parties')
        .insert(model.toJson())
        .select()
        .single();
    return EventModel.fromJson(inserted);
  }

  @override
  Future<List<EventEntity>> fetchHostEvents(String hostId) async {
    final rows = await SupabaseService.client
        .from('parties')
        .select()
        .eq('host_id', hostId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => EventModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventEntity?> fetchEventByJoinCode(String joinCode) async {
    final row = await SupabaseService.client
        .from('parties')
        .select()
        .eq('join_code', joinCode)
        .maybeSingle();
    if (row == null) return null;
    return EventModel.fromJson(row);
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    await SupabaseService.client
        .from('parties')
        .update(model.toJson())
        .eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await SupabaseService.client.from('parties').delete().eq('id', eventId);
  }

  @override
  Future<Map<String, int>> fetchEventStats(String eventId) async {
    final photos = await SupabaseService.client
        .from('photos')
        .select('id')
        .eq('album_id', eventId);
    final members = await SupabaseService.client
        .from('party_members')
        .select('id')
        .eq('party_id', eventId);
    return {
      'photos': (photos as List).length,
      'guests': (members as List).length,
    };
  }
}
