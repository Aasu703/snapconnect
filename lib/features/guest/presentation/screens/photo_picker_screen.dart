import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapconnect/core/constants/app_colors.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:snapconnect/core/providers/session_provider.dart';
import 'package:snapconnect/core/api/api.client.dart';
import 'package:snapconnect/core/api/api.endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Streamlined photo picker for guests to select and upload
/// photos to an event album.
class PhotoPickerScreen extends ConsumerStatefulWidget {
  const PhotoPickerScreen({super.key, required this.joinCode});
  final String joinCode;

  @override
  ConsumerState<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends ConsumerState<PhotoPickerScreen> {
  final _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  bool _isUploading = false;
  int _uploadedCount = 0;
  String _eventId = '';

  @override
  void initState() {
    super.initState();
    _resolveEventId();
  }

  Future<void> _resolveEventId() async {
    try {
      final response = await ApiClient().get(ApiEndpoints.partyByCode(widget.joinCode));
      if (response.statusCode == 200 && response.data['data'] != null) {
        _eventId = response.data['data']['id'].toString();
      }
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(
          files.take(AppConstants.maxUploadPhotos - _selectedFiles.length),
        );
      });
    }
  }

  Future<void> _capturePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file != null && _selectedFiles.length < AppConstants.maxUploadPhotos) {
      setState(() => _selectedFiles.add(file));
    }
  }

  void _removeAt(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  Future<void> _upload() async {
    if (_selectedFiles.isEmpty || _isUploading || _eventId.isEmpty) return;

    final user = ref.read(sessionProvider);
    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
    });

    int successCount = 0;

    for (final file in _selectedFiles) {
      try {
        final formData = FormData.fromMap({
          'album_id': _eventId,
          'title': '',
          'uploaded_by': user?.id ?? 'guest',
          'uploaded_by_name': user?.name ?? 'Guest',
        });

        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          formData.files.add(MapEntry(
            'file',
            MultipartFile.fromBytes(bytes, filename: file.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'file',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ));
        }

        final response = await ApiClient().post(
          ApiEndpoints.photoUpload,
          data: formData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          successCount++;
        }

        setState(() => _uploadedCount++);
      } catch (_) {
        setState(() => _uploadedCount++);
      }
    }

    if (!mounted) return;

    if (successCount > 0) {
      context.go(
        '/upload-success?count=$successCount&joinCode=${widget.joinCode}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _selectedFiles.isEmpty
        ? 0.0
        : _uploadedCount / _selectedFiles.length;

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
          'Pick Photos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_selectedFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedFiles.length}/${AppConstants.maxUploadPhotos}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Source Buttons ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: _isUploading ? null : _pickFromGallery,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: _isUploading ? null : _capturePhoto,
                  ),
                ),
              ],
            ),
          ),
          // ── Selected Photos Grid ──────────────────────────────────
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildPickPrompt()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedFiles[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeAt(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          if (_isUploading && index < _uploadedCount)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 30 * index),
                        duration: 250.ms,
                      );
                    },
                  ),
          ),
          // ── Upload Bar ────────────────────────────────────────────
          if (_selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Column(
                children: [
                  if (_isUploading) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                    const Gap(12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6C63FF)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _isUploading ? null : _upload,
                          child: Center(
                            child: _isUploading
                                ? Text(
                                    'Uploading $_uploadedCount/${_selectedFiles.length}...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.cloud_upload_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Upload ${_selectedFiles.length} Photo${_selectedFiles.length != 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickPrompt() {
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
              Icons.add_photo_alternate_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const Gap(20),
          Text(
            'Select photos to share',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            'Pick from gallery or capture a new photo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
