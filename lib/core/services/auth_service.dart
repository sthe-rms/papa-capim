import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/services/api_service.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final SecureStorageService _storageService = SecureStorageService();

  AuthService(this._apiService);

  Future<bool> login(String login, String password) async {
    final body = jsonEncode({
      'login': login,
      'password': password
    });
    
    print('LOGIN: $login');
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('RESPOSTA: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token'];
      final String userLogin = data['user_login'];

      await _storageService.writeToken(token);
      await _storageService.writeUserLogin(userLogin);
      
      print('TOKEN SALVO: $token');
      print('USERLOGIN SALVO: $userLogin');
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Login ou senha incorretos');
    } else {
      throw Exception('Erro: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> register(String name, String login, String password, String passwordConfirmation) async {
    final body = jsonEncode({
      'user': {
        'login': login,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }
    });

    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Erro no registro');
    }
  }

  Future<void> logout() async {
    final token = await _storageService.readToken();
    if (token != null) {
      await _storageService.deleteToken();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.readToken();
    return token != null;
  }

  Future<String?> getCurrentUserLogin() async {
    return await _storageService.readUserLogin();
  }
}