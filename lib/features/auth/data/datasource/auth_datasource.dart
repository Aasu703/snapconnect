import 'package:snapconnect/features/auth/data/datasource/remote/auth_remote_datasource.dart';

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  // Future<String> uploadPhoto(File photo);
  Future<AuthApiModel?> getUserById(String authId);
  Future<AuthApiModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    // File? imageFile,
  });
  Future<bool> requestPasswordReset(String email);
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  });
}
