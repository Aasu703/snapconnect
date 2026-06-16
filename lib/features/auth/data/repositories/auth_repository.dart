import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api.endpoints.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete implementation of [IAuthRepository] using REST API via Dio.
class AuthRepositoryImpl implements IAuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.baseUrl + ApiEndpoints.userLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success']) {
        final token = response.data['token'];
        final userJson = response.data['data']['user'];
        await _storage.write(key: 'auth_token', value: token);
        return {
          'user': UserModel.fromJson(userJson),
          'token': token,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.baseUrl + ApiEndpoints.userRegister,
        data: data,
      );
      return response.data['success'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<UserModel?> whoAmI() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _dio.get(
        ApiEndpoints.baseUrl + ApiEndpoints.userWhoAmI,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success']) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
