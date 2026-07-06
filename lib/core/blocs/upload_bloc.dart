import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:equatable/equatable.dart';

// ── Events ─────────────────────────────────────────────────────────────────
abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadPickPhotos extends UploadEvent {}

class UploadCapturePhoto extends UploadEvent {}

class UploadRemoveAt extends UploadEvent {
  final int index;
  const UploadRemoveAt(this.index);

  @override
  List<Object?> get props => [index];
}

class UploadRetryItem extends UploadEvent {
  final int index;
  final String albumId;
  final UserModel user;
  final String? title;

  const UploadRetryItem({
    required this.index,
    required this.albumId,
    required this.user,
    this.title,
  });

  @override
  List<Object?> get props => [index, albumId, user, title];
}

class UploadProgress extends UploadEvent {
  final List<UploadItem> items;
  final int uploadedCount;

  const UploadProgress({required this.items, required this.uploadedCount});

  @override
  List<Object?> get props => [items, uploadedCount];
}

class UploadAll extends UploadEvent {
  final String albumId;
  final UserModel user;
  final String? title;

  const UploadAll({
    required this.albumId,
    required this.user,
    this.title,
  });

  @override
  List<Object?> get props => [albumId, user, title];
}

class UploadReset extends UploadEvent {}

// ── Bloc ───────────────────────────────────────────────────────────────────
class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final PhotosController _photosController;

  UploadBloc(this._photosController) : super(const UploadState()) {
    on<UploadPickPhotos>(_onPickPhotos);
    on<UploadCapturePhoto>(_onCapturePhoto);
    on<UploadRemoveAt>(_onRemoveAt);
    on<UploadRetryItem>(_onRetryItem);
    on<UploadProgress>(_onProgress);
    on<UploadAll>(_onUploadAll);
    on<UploadReset>(_onReset);
    sl<AppLogger>().debug('UploadBloc initialized');
  }

  Future<void> _onPickPhotos(UploadPickPhotos event, Emitter<UploadState> emit) async {
    sl<AppLogger>().info('Picking photos for upload...');
    final files = await _photosController.pickMultiplePhotos();
    if (files.isEmpty) {
      sl<AppLogger>().debug('No photos selected');
      return;
    }

    final merged = <UploadItem>[
      ...state.items,
      ...files.map((file) => UploadItem(file: file)),
    ];
    final validation = await _photosController.validateFiles(
      merged.map((item) => item.file).toList(),
    );
    if (validation != null) {
      sl<AppLogger>().warning('Validation error while picking photos: $validation');
      emit(state.copyWith(error: validation));
      return;
    }
    emit(state.copyWith(
      items: merged,
      totalCount: merged.length,
      error: null,
    ));
    sl<AppLogger>().good('${files.length} photos added to upload queue');
  }

  Future<void> _onCapturePhoto(UploadCapturePhoto event, Emitter<UploadState> emit) async {
    sl<AppLogger>().info('Capturing photo...');
    final file = await _photosController.capturePhoto();
    if (file == null) {
      sl<AppLogger>().debug('No photo captured');
      return;
    }

    final merged = <UploadItem>[...state.items, UploadItem(file: file)];
    final validation = await _photosController.validateFiles(
      merged.map((item) => item.file).toList(),
    );
    if (validation != null) {
      sl<AppLogger>().warning('Validation error while capturing photo: $validation');
      emit(state.copyWith(error: validation));
      return;
    }
    emit(state.copyWith(
      items: merged,
      totalCount: merged.length,
      error: null,
    ));
    sl<AppLogger>().good('Captured photo added to upload queue');
  }

  void _onRemoveAt(UploadRemoveAt event, Emitter<UploadState> emit) {
    final items = [...state.items]..removeAt(event.index);
    emit(state.copyWith(items: items, totalCount: items.length));
    sl<AppLogger>().info('Removed item at index ${event.index}');
  }

  Future<void> _onRetryItem(UploadRetryItem event, Emitter<UploadState> emit) async {
    if (event.index < 0 || event.index >= state.items.length) return;
    sl<AppLogger>().info('Retrying upload for item at index ${event.index}');

    final items = [...state.items];
    items[event.index] = items[event.index].copyWith(
      status: UploadItemStatus.pending,
      error: null,
    );
    emit(state.copyWith(items: items, error: null));
    add(UploadAll(albumId: event.albumId, user: event.user, title: event.title));
  }

  void _onProgress(UploadProgress event, Emitter<UploadState> emit) {
    emit(state.copyWith(
      items: event.items,
      isUploading: true,
      uploadedCount: event.uploadedCount,
      totalCount: event.items.length,
      error: null,
    ));
  }

  Future<void> _onUploadAll(UploadAll event, Emitter<UploadState> emit) async {
    if (state.items.isEmpty || state.isUploading) return;
    sl<AppLogger>().info('Starting upload of ${state.items.length} items to album ${event.albumId}');

    emit(state.copyWith(isUploading: true, error: null));

    final nextState = await _photosController.uploadSequentially(
      items: state.items,
      albumId: event.albumId,
      user: event.user,
      title: event.title,
      onProgress: (items, uploadedCount) {
        add(UploadProgress(items: items, uploadedCount: uploadedCount));
      },
    );
    
    emit(nextState);
    if (nextState.error != null) {
      sl<AppLogger>().error('Upload completed with errors: ${nextState.error}');
    } else {
      sl<AppLogger>().good('Upload completed successfully');
    }
  }

  void _onReset(UploadReset event, Emitter<UploadState> emit) {
    sl<AppLogger>().info('Resetting upload state');
    emit(const UploadState());
  }
}
