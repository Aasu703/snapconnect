import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapconnect/core/constants/app_constants.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/services/cloudinary_service.dart';
import 'package:snapconnect/core/services/supabase_service.dart';

/// Supported upload status values for each selected photo.
enum UploadItemStatus { pending, uploading, done, error }

/// Upload item state used by the upload workflow UI.
class UploadItem {
  const UploadItem({
    required this.file,
    this.status = UploadItemStatus.pending,
    this.uploadedUrl,
    this.error,
  });

  final XFile file;
  final UploadItemStatus status;
  final String? uploadedUrl;
  final String? error;

  /// Returns a copy with selective updates.
  UploadItem copyWith({
    XFile? file,
    UploadItemStatus? status,
    String? uploadedUrl,
    String? error,
  }) {
    return UploadItem(
      file: file ?? this.file,
      status: status ?? this.status,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      error: error,
    );
  }
}

/// Aggregated upload state for screen-level rendering.
class UploadState {
  const UploadState({
    this.items = const <UploadItem>[],
    this.isUploading = false,
    this.uploadedCount = 0,
    this.totalCount = 0,
    this.error,
  });

  final List<UploadItem> items;
  final bool isUploading;
  final int uploadedCount;
  final int totalCount;
  final String? error;

  /// Returns a copy with selective updates.
  UploadState copyWith({
    List<UploadItem>? items,
    bool? isUploading,
    int? uploadedCount,
    int? totalCount,
    String? error,
  }) {
    return UploadState(
      items: items ?? this.items,
      isUploading: isUploading ?? this.isUploading,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }

  /// True when all selected photos finished uploading.
  bool get isComplete => totalCount > 0 && uploadedCount == totalCount;
}

/// Handles picking media and sequential cloud/database uploads.
class PhotosController {
  PhotosController({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  /// Picks multiple photos from gallery or desktop file picker.
  Future<List<XFile>> pickMultiplePhotos() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        return const <XFile>[];
      }

      return result.files
          .where((file) => file.path != null)
          .map((file) => XFile(file.path!))
          .toList();
    }

    final files = await _imagePicker.pickMultiImage(
      limit: AppConstants.maxUploadPhotos,
    );
    return files;
  }

  /// Captures a single image from camera.
  Future<XFile?> capturePhoto() {
    return _imagePicker.pickImage(source: ImageSource.camera);
  }

  /// Validates upload constraints for count and file size.
  Future<String?> validateFiles(List<XFile> files) async {
    if (files.length > AppConstants.maxUploadPhotos) {
      return 'You can upload up to ${AppConstants.maxUploadPhotos} photos at a time.';
    }

    for (final file in files) {
      final size = await file.length();
      if (size > AppConstants.maxUploadBytes) {
        return 'Each file must be smaller than 10MB.';
      }
    }

    return null;
  }

  /// Uploads selected files one-by-one and inserts photo rows into Supabase.
  Future<UploadState> uploadSequentially({
    required List<UploadItem> items,
    required String albumId,
    required UserModel user,
    String? title,
  }) async {
    var updatedItems = List<UploadItem>.from(items);
    var uploaded = 0;

    for (var i = 0; i < updatedItems.length; i++) {
      final item = updatedItems[i];

      if (item.status == UploadItemStatus.done) {
        uploaded++;
        continue;
      }

      updatedItems[i] = item.copyWith(
        status: UploadItemStatus.uploading,
        error: null,
      );

      try {
        final cloudinaryUrl = await CloudinaryService.instance.uploadXFile(
          item.file,
        );
        if (cloudinaryUrl == null) {
          throw Exception('Failed to upload to Cloudinary.');
        }

        if (SupabaseService.isInitialized) {
          await SupabaseService.client.from('photos').insert({
            'album_id': albumId,
            'url': cloudinaryUrl,
            'title': title?.trim().isEmpty ?? true ? null : title!.trim(),
            'uploaded_by': user.id,
            'uploaded_by_name': user.name,
          });

          await _setCoverIfNeeded(albumId: albumId, coverUrl: cloudinaryUrl);
        }

        updatedItems[i] = updatedItems[i].copyWith(
          status: UploadItemStatus.done,
          uploadedUrl: cloudinaryUrl,
        );
        uploaded++;
      } catch (error) {
        updatedItems[i] = updatedItems[i].copyWith(
          status: UploadItemStatus.error,
          error: error.toString(),
        );
      }
    }

    return UploadState(
      items: updatedItems,
      isUploading: false,
      uploadedCount: uploaded,
      totalCount: updatedItems.length,
    );
  }

  Future<void> _setCoverIfNeeded({
    required String albumId,
    required String coverUrl,
  }) async {
    final existing = await SupabaseService.client
        .from('albums')
        .select('cover_url')
        .eq('id', albumId)
        .maybeSingle();

    final currentCover = existing?['cover_url']?.toString();
    if (currentCover == null || currentCover.isEmpty) {
      await SupabaseService.client
          .from('albums')
          .update({'cover_url': coverUrl})
          .eq('id', albumId);
    }
  }
}
