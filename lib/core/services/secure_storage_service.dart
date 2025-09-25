import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  final String _authTokenKey = 'auth_token';

  Future<void> writeToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }
}
