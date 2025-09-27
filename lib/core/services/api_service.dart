import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/models/user_model.dart';
import 'package:papa_capim/core/models/post_model.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.papacapim.just.pro.br';
  final SecureStorageService _storageService = SecureStorageService();

  String get baseUrl => _baseUrl;

  Future<String> _getRequiredAuthToken() async {
    final token = await _storageService.readToken();
    if (token == null) {
      throw Exception(
        'Token de autenticação não encontrado. Faça o login novamente.',
      );
    }
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getRequiredAuthToken();
    return {
      'Content-Type': 'application/json',
      'x-session-token': token,
    };
  }

  Future<User> getMyProfile() async {
    final headers = await _getAuthHeaders();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken(); // Limpa token inválido
      throw Exception('Sessão expirada. Faça o login novamente.');
    } else {
      throw Exception(
        'Falha ao carregar dados do perfil (Cód: ${response.statusCode})',
      );
    }
  }
  Future<List<User>> getUsers({String? search, int page = 1}) async {
    final headers = await _getAuthHeaders();
    
    final params = {'page': page.toString()};
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/users').replace(queryParameters: params),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((userJson) => User.fromJson(userJson)).toList();
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao buscar usuários: ${response.statusCode}');
    }
  }

  Future<User> getUserByLogin(String login) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$login'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else if (response.statusCode == 404) {
      throw Exception('Usuário não encontrado.');
    } else {
      throw Exception('Falha ao buscar usuário: ${response.statusCode}');
    }
  }

  Future<User> updateUser(int userId, {String? name, String? login, String? password, String? passwordConfirmation}) async {
    final headers = await _getAuthHeaders();
    
    final Map<String, dynamic> userData = {};
    if (name != null) userData['name'] = name;
    if (login != null) userData['login'] = login;
    if (password != null) userData['password'] = password;
    if (passwordConfirmation != null) userData['password_confirmation'] = passwordConfirmation;

    final response = await http.patch(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: headers,
      body: jsonEncode({'user': userData}),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao atualizar usuário: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(int userId) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      await _storageService.deleteToken(); // Limpa token após excluir conta
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao excluir usuário: ${response.statusCode}');
    }
  }

}