import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/providers/controllers_provider.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';

// ── State ──────────────────────────────────────────────────────────────────

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._photosController) : super(const UploadState());

  final PhotosController _photosController;

  Future<void> pickPhotos() async {
    final files = await _photosController.pickMultiplePhotos();
    if (files.isEmpty) return;

    final merged = <UploadItem>[
      ...state.items,
      ...files.map((file) => UploadItem(file: file)),
    ];
    final validation = await _photosController.validateFiles(
      merged.map((item) => item.file).toList(),
    );
    if (validation != null) {
      state = state.copyWith(error: validation);
      return;
    }
    state = state.copyWith(
      items: merged,
      totalCount: merged.length,
      error: null,
    );
  }

  Future<void> capturePhoto() async {
    final file = await _photosController.capturePhoto();
    if (file == null) return;

    final merged = <UploadItem>[...state.items, UploadItem(file: file)];
    final validation = await _photosController.validateFiles(
      merged.map((item) => item.file).toList(),
    );
    if (validation != null) {
      state = state.copyWith(error: validation);
      return;
    }
    state = state.copyWith(
      items: merged,
      totalCount: merged.length,
      error: null,
    );
  }

  void removeAt(int index) {
    final items = [...state.items]..removeAt(index);
    state = state.copyWith(items: items, totalCount: items.length);
  }

  Future<void> retryItem({
    required int index,
    required String albumId,
    required UserModel user,
    String? title,
  }) async {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items[index] = items[index].copyWith(
      status: UploadItemStatus.pending,
      error: null,
    );
    state = state.copyWith(items: items, error: null);
    await uploadAll(albumId: albumId, user: user, title: title);
  }

  Future<void> uploadAll({
    required String albumId,
    required UserModel user,
    String? title,
  }) async {
    if (state.items.isEmpty || state.isUploading) return;

    state = state.copyWith(isUploading: true, error: null);

    final nextState = await _photosController.uploadSequentially(
      items: state.items,
      albumId: albumId,
      user: user,
      title: title,
      onProgress: (items, uploadedCount) {
        state = state.copyWith(
          items: items,
          isUploading: true,
          uploadedCount: uploadedCount,
          totalCount: items.length,
          error: null,
        );
      },
    );

    state = nextState;
  }

  void reset() => state = const UploadState();
}

// ── Provider ───────────────────────────────────────────────────────────────

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(ref.watch(photosControllerProvider)),
);
