import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Personalized view showing photos contributed by the current guest.
class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key, required this.joinCode});
  final String joinCode;

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  List<PhotoModel> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPhotos();
  }

  Future<void> _loadMyPhotos() async {
    final user = context.read<SessionCubit>().state;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final partyResponse = await ApiClient().get(ApiEndpoints.partyByCode(widget.joinCode));
      
      if (partyResponse.statusCode != 200 || partyResponse.data['data'] == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      final party = partyResponse.data['data'];

      final photosResponse = await ApiClient().get(ApiEndpoints.albumPhotos(party['album_id']));

      if (mounted) {
        setState(() {
          if (photosResponse.statusCode == 200) {
            final allPhotos = (photosResponse.data['data'] as List)
                .map((r) => PhotoModel.fromJson(r))
                .toList();
            _photos = allPhotos.where((p) => p.uploadedBy == user.id).toList();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete Photo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove this photo from the event album?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiClient().delete(ApiEndpoints.photo(photoId));
      setState(() => _photos.removeWhere((p) => p.id == photoId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete photo')));
      }
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
        title: const Text(
          'My Photos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _photos.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
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
                        ),
                      ),
                      // Bottom info overlay
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
                          child: Text(
                            timeago.format(photo.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      // Delete button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(photo.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 300.ms,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const Gap(16),
          Text(
            'No contributions yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            'Photos you upload will appear here',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
          const Gap(24),
          OutlinedButton.icon(
            onPressed: () => context.push('/guest/${widget.joinCode}/pick'),
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('Upload Photos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
