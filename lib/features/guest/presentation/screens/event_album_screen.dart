import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Collaborative event album grid for guests with real-time
/// photo display and upload FAB.
class EventAlbumScreen extends StatefulWidget {
  const EventAlbumScreen({super.key, required this.joinCode});
  final String joinCode;

  @override
  State<EventAlbumScreen> createState() => _EventAlbumScreenState();
}

class _EventAlbumScreenState extends State<EventAlbumScreen> {
  List<PhotoModel> _photos = [];
  String _eventName = '';
  String _eventId = '';
  bool _isLoading = true;

  @override
  void initState() {
    // this means that when the screen is first created, it will call the _loadData() method to fetch the event and photo data from the Supabase database. The _loadData() method will then update the state of the screen with the fetched data, which will trigger a rebuild of the UI to display the photos and event information.
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final partyResponse = await ApiClient().get(ApiEndpoints.partyByCode(widget.joinCode));
      
      if (partyResponse.statusCode != 200 || partyResponse.data['data'] == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      final party = partyResponse.data['data'];

      _eventId = party['id'].toString();
      _eventName = party['name'].toString();

      final photosResponse = await ApiClient().get(ApiEndpoints.albumPhotos(party['album_id']));

      if (mounted) {
        setState(() {
          if (photosResponse.statusCode == 200) {
            _photos = (photosResponse.data['data'] as List)
                .map((r) => PhotoModel.fromJson(r))
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _eventName.isEmpty ? 'Event Album' : _eventName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_outlined, color: Colors.white70),
            tooltip: 'My Photos',
            onPressed: () =>
                context.push('/guest/${widget.joinCode}/my-photos'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _photos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.85,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return _PhotoCard(photo: photo)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 40 * index),
                        duration: 300.ms,
                      )
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                      );
                },
              ),
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF6C63FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/guest/${widget.joinCode}/pick'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Photos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const Gap(20),
          Text(
            'No photos yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Be the first to share a moment!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photo});
  final PhotoModel photo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: photo.url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            errorWidget: (_, _, _) => Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: const Icon(
                Icons.broken_image_rounded,
                color: Colors.white24,
              ),
            ),
          ),
          // Bottom gradient overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.uploadedByName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    timeago.format(photo.createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
