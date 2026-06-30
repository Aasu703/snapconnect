import 'package:snapconnect/core/storage/secure_token.dart';
import 'package:snapconnect/features/auth/domain/usecases/user_token.dart';

class UserTokenStorage {
  final SecureStorageManager _storageManager;

  UserTokenStorage(this._storageManager);

  static const _accesstoken = 'access_token';
  static const _refreshtoken = 'refresh_token';

  Future<void> saveTokens(UserToken tokens) async {
    await _storageManager.writeData(
      key: _accesstoken,
      value: tokens.accessToken,
    );
    await _storageManager.writeData(
      key: _refreshtoken,
      value: tokens.refreshToken,
    );
  }

  Future<UserToken?> getToken() async {
    final accessToken = await _storageManager.readData(key: _accesstoken);
    final refreshToken = await _storageManager.readData(key: _refreshtoken);

    if (accessToken != null && refreshToken != null) {
      return UserToken(accessToken: accessToken, refreshToken: refreshToken);
    }
    return null;
  }

  Future<void> deleteTokens() async {
    await _storageManager.deleteData(key: _accesstoken);
    await _storageManager.deleteData(key: _refreshtoken);
  }
}
