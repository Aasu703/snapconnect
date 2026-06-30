import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

/// Host album management screen with multi-select, delete,
/// highlight, and flag capabilities over event photos.
class HostAlbumScreen extends StatefulWidget {
  const HostAlbumScreen({super.key, required this.joinCode});
  final String joinCode;

  @override
  State<HostAlbumScreen> createState() => _HostAlbumScreenState();
}

class _HostAlbumScreenState extends State<HostAlbumScreen> {
  List<PhotoModel> _photos = [];
  final Set<String> _selected = {};
  bool _isLoading = true;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      // Fetch the party ID from join code, then its photos
      final party = await SupabaseService.client
          .from('parties')
          .select('id')
          .eq('join_code', widget.joinCode)
          .maybeSingle();

      if (party == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final rows = await SupabaseService.client
          .from('photos')
          .select()
          .eq('album_id', party['id'])
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _photos = (rows as List<dynamic>)
              .map((r) => PhotoModel.fromJson(r as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _isSelecting = false;
      } else {
        _selected.add(id);
        _isSelecting = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Photos',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete ${_selected.length} photo(s)? This cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final id in _selected) {
        await SupabaseService.client.from('photos').delete().eq('id', id);
      }
      setState(() {
        _photos.removeWhere((p) => _selected.contains(p.id));
        _selected.clear();
        _isSelecting = false;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete some photos')),
        );
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
        title: Text(
          _isSelecting
              ? '${_selected.length} selected'
              : 'Manage Album',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                  onPressed: _deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => setState(() {
                    _selected.clear();
                    _isSelecting = false;
                  }),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _photos.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final isSelected = _selected.contains(photo.id);
                    return GestureDetector(
                      onLongPress: () => _toggleSelect(photo.id),
                      onTap: _isSelecting
                          ? () => _toggleSelect(photo.id)
                          : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: photo.url,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                child: const Icon(Icons.broken_image_rounded,
                                    color: Colors.white24),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.primary.withValues(alpha: 0.4),
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 30 * index),
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
          Icon(Icons.photo_library_outlined,
              size: 48, color: Colors.white.withValues(alpha: 0.3)),
          const Gap(16),
          Text(
            'No photos yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            'Photos uploaded by guests will appear here',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
