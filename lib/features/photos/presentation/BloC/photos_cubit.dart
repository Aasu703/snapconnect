import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/photos_repository.dart';
import 'photos_state.dart';

class PhotosCubit extends Cubit<PhotosState> {
  final PhotosRepository _photosRepository;

  PhotosCubit(this._photosRepository) : super(PhotosInitial());

  Future<void> fetchPhotos({String? albumId, String? userId, bool reset = false}) async {
    if (reset) {
      emit(PhotosLoading());
    } else if (state is PhotosLoaded) {
      if (!(state as PhotosLoaded).hasMore) return;
    }

    int page = reset ? 1 : (state is PhotosLoaded ? (state as PhotosLoaded).page + 1 : 1);

    try {
      final result = await _photosRepository.fetchPhotos(
        albumId: albumId,
        userId: userId,
        page: page,
      );

      final List<Photo> currentPhotos = reset ? [] : (state is PhotosLoaded ? (state as PhotosLoaded).photos : []);
      
      emit(PhotosLoaded(
        photos: [...currentPhotos, ...result['photos']],
        hasMore: result['hasMore'],
        page: page,
      ));
    } catch (e) {
      emit(PhotosError(e.toString()));
    }
  }
}
