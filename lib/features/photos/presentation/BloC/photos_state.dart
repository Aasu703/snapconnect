import 'package:equatable/equatable.dart';
import '../../../../app/lib/types.dart'; // Wait, I need to check where types are in flutter

// Actually, I'll define a simple Photo model for Flutter if it doesn't exist.
class Photo extends Equatable {
  final String id;
  final String albumId;
  final String url;
  final String? title;
  final String? uploadedBy;
  final String? uploadedByName;
  final String? createdAt;

  const Photo({
    required this.id,
    required this.albumId,
    required this.url,
    this.title,
    this.uploadedBy,
    this.uploadedByName,
    this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? '',
      albumId: json['album_id'] ?? '',
      url: json['url'] ?? '',
      title: json['title'],
      uploadedBy: json['uploaded_by'],
      uploadedByName: json['uploaded_by_name'],
      createdAt: json['created_at'],
    );
  }

  @override
  List<Object?> get props => [id, albumId, url, title, uploadedBy, uploadedByName, createdAt];
}

abstract class PhotosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhotosInitial extends PhotosState {}

class PhotosLoading extends PhotosState {}

class PhotosLoaded extends PhotosState {
  final List<Photo> photos;
  final bool hasMore;
  final int page;

  PhotosLoaded({required this.photos, required this.hasMore, required this.page});

  @override
  List<Object?> get props => [photos, hasMore, page];
}

class PhotosError extends PhotosState {
  final String message;

  PhotosError(this.message);

  @override
  List<Object?> get props => [message];
}
