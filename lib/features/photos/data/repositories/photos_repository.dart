import 'package:dio/dio.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';
import 'package:snapconnect/features/photos/presentation/BloC/photos_state.dart';

class PhotosRepository {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchPhotos({String? albumId, String? userId, int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.serverUrl}api/photos', // Use Next.js API as proxy or call Supabase directly
        queryParameters: {
          'album_id': albumId,
          'user_id': userId,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        final photos = data.map((json) => Photo.fromJson(json)).toList();
        return {
          'photos': photos,
          'hasMore': data.length == limit,
        };
      } else {
        throw Exception('Failed to fetch photos');
      }
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }
}
