import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapconnect/features/albums/albums_controller.dart';
import 'package:snapconnect/features/onboarding/onboarding_controller.dart';
import 'package:snapconnect/features/party/party_controller.dart';
import 'package:snapconnect/features/photos/photos_controller.dart';
import 'package:snapconnect/features/profile/profile_controller.dart';

final onboardingControllerProvider = Provider<OnboardingController>(
  (ref) => OnboardingController(),
);

final albumsControllerProvider = Provider<AlbumsController>(
  (ref) => AlbumsController(),
);

final photosControllerProvider = Provider<PhotosController>(
  (ref) => PhotosController(),
);

final partyControllerProvider = Provider<PartyController>(
  (ref) => PartyController(),
);

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(),
);
