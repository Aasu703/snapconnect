import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/models/album_model.dart';
import 'package:snapconnect/core/models/photo_model.dart';
import 'package:snapconnect/features/albums/albums_controller.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:equatable/equatable.dart';

// ── Events ─────────────────────────────────────────────────────────────────
abstract class AlbumsEvent extends Equatable {
  const AlbumsEvent();
  @override
  List<Object?> get props => [];
}

class FetchAlbums extends AlbumsEvent {}

class FetchUserAlbums extends AlbumsEvent {
  final String userId;
  const FetchUserAlbums(this.userId);
  @override
  List<Object?> get props => [userId];
}

class FetchAlbumPhotos extends AlbumsEvent {
  final String albumId;
  const FetchAlbumPhotos(this.albumId);
  @override
  List<Object?> get props => [albumId];
}

// ── State ──────────────────────────────────────────────────────────────────
class AlbumsState extends Equatable {
  final List<AlbumModel>? albums;
  final bool isLoadingAlbums;
  final String? albumsError;

  final List<AlbumModel>? userAlbums;
  final bool isLoadingUserAlbums;
  final String? userAlbumsError;

  final List<PhotoModel>? albumPhotos;
  final bool isLoadingAlbumPhotos;
  final String? albumPhotosError;

  const AlbumsState({
    this.albums,
    this.isLoadingAlbums = false,
    this.albumsError,
    this.userAlbums,
    this.isLoadingUserAlbums = false,
    this.userAlbumsError,
    this.albumPhotos,
    this.isLoadingAlbumPhotos = false,
    this.albumPhotosError,
  });

  AlbumsState copyWith({
    List<AlbumModel>? albums,
    bool? isLoadingAlbums,
    String? albumsError,
    List<AlbumModel>? userAlbums,
    bool? isLoadingUserAlbums,
    String? userAlbumsError,
    List<PhotoModel>? albumPhotos,
    bool? isLoadingAlbumPhotos,
    String? albumPhotosError,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      isLoadingAlbums: isLoadingAlbums ?? this.isLoadingAlbums,
      albumsError: albumsError ?? this.albumsError,
      userAlbums: userAlbums ?? this.userAlbums,
      isLoadingUserAlbums: isLoadingUserAlbums ?? this.isLoadingUserAlbums,
      userAlbumsError: userAlbumsError ?? this.userAlbumsError,
      albumPhotos: albumPhotos ?? this.albumPhotos,
      isLoadingAlbumPhotos: isLoadingAlbumPhotos ?? this.isLoadingAlbumPhotos,
      albumPhotosError: albumPhotosError ?? this.albumPhotosError,
    );
  }

  @override
  List<Object?> get props => [
        albums,
        isLoadingAlbums,
        albumsError,
        userAlbums,
        isLoadingUserAlbums,
        userAlbumsError,
        albumPhotos,
        isLoadingAlbumPhotos,
        albumPhotosError,
      ];
}

// ── Bloc ───────────────────────────────────────────────────────────────────
class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  final AlbumsController _albumsController;

  AlbumsBloc(this._albumsController) : super(const AlbumsState()) {
    on<FetchAlbums>(_onFetchAlbums);
    on<FetchUserAlbums>(_onFetchUserAlbums);
    on<FetchAlbumPhotos>(_onFetchAlbumPhotos);
    sl<AppLogger>().debug('AlbumsBloc initialized');
  }

  Future<void> _onFetchAlbums(FetchAlbums event, Emitter<AlbumsState> emit) async {
    emit(state.copyWith(isLoadingAlbums: true, albumsError: null));
    sl<AppLogger>().info('Fetching albums');
    try {
      final albums = await _albumsController.fetchAlbums();
      emit(state.copyWith(albums: albums, isLoadingAlbums: false));
      sl<AppLogger>().good('Fetched ${albums.length} albums');
    } catch (e) {
      sl<AppLogger>().error('Error fetching albums: $e');
      emit(state.copyWith(isLoadingAlbums: false, albumsError: e.toString()));
    }
  }

  Future<void> _onFetchUserAlbums(FetchUserAlbums event, Emitter<AlbumsState> emit) async {
    emit(state.copyWith(isLoadingUserAlbums: true, userAlbumsError: null));
    sl<AppLogger>().info('Fetching albums for user: ${event.userId}');
    try {
      final albums = await _albumsController.fetchUserAlbums(event.userId);
      emit(state.copyWith(userAlbums: albums, isLoadingUserAlbums: false));
      sl<AppLogger>().good('Fetched ${albums.length} user albums');
    } catch (e) {
      sl<AppLogger>().error('Error fetching user albums: $e');
      emit(state.copyWith(isLoadingUserAlbums: false, userAlbumsError: e.toString()));
    }
  }

  Future<void> _onFetchAlbumPhotos(FetchAlbumPhotos event, Emitter<AlbumsState> emit) async {
    emit(state.copyWith(isLoadingAlbumPhotos: true, albumPhotosError: null));
    sl<AppLogger>().info('Fetching photos for album: ${event.albumId}');
    try {
      final photos = await _albumsController.fetchAlbumPhotos(event.albumId);
      emit(state.copyWith(albumPhotos: photos, isLoadingAlbumPhotos: false));
      sl<AppLogger>().good('Fetched ${photos.length} photos');
    } catch (e) {
      sl<AppLogger>().error('Error fetching album photos: $e');
      emit(state.copyWith(isLoadingAlbumPhotos: false, albumPhotosError: e.toString()));
    }
  }
}
