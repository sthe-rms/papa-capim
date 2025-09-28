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
    try {
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _userLoginKey);
      print('TOKEN E USERLOGIN REMOVIDOS DO STORAGE');
    } catch (e) {
      print('Erro ao remover token: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      print('STORAGE COMPLETAMENTE LIMPO');
    } catch (e) {
      print('Erro ao limpar storage: $e');
    }
  }
}