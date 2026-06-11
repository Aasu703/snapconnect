import 'package:dio/dio.dart';
import '../../../../core/api/api.endpoints.dart';
import '../presentation/BloC/photos_state.dart';

class PhotosRepository {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchPhotos({String? albumId, String? userId, int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.serverUrl}api/photos', // Use Next.js API as proxy or call Supabase directly
        // Wait, if I call Next.js API, it's at localhost:3000/api/photos
        queryParameters: {
          if (albumId != null) 'album_id': albumId,
          if (userId != null) 'user_id': userId,
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
