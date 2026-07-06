import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';
import 'package:snapconnect/core/models/user_model.dart';
import 'package:snapconnect/core/logger/app_logger.dart';
import 'package:snapconnect/core/di/injection_container.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileStats stats;
  const ProfileLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileController _profileController;

  ProfileCubit(this._profileController) : super(ProfileInitial()) {
    sl<AppLogger>().debug('ProfileCubit initialized');
  }

  Future<void> fetchStats(UserModel? user) async {
    if (user == null) {
      sl<AppLogger>().warning('fetchStats called with null user');
      emit(const ProfileLoaded(
        ProfileStats(photosUploaded: 0, albumsCreated: 0, partiesJoined: 0),
      ));
      return;
    }

    emit(ProfileLoading());
    sl<AppLogger>().info('Fetching profile stats for user: ${user.id}');
    try {
      final stats = await _profileController.fetchStats(user.id);
      emit(ProfileLoaded(stats));
      sl<AppLogger>().good('Profile stats fetched successfully');
    } catch (e) {
      sl<AppLogger>().error('Error fetching profile stats: $e');
      emit(ProfileError(e.toString()));
    }
  }
}
