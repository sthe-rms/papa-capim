import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  final String _authTokenKey = 'auth_token';
  final String _userLoginKey = 'user_login';

  Future<void> writeToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  Future<void> writeUserLogin(String userLogin) async {
    await _storage.write(key: _userLoginKey, value: userLogin);
  }

  Future<String?> readUserLogin() async {
    return await _storage.read(key: _userLoginKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _userLoginKey);
  }
}
