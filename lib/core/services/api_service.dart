import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/models/user_model.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';

class ApiService {
  final String _baseUrl = "https://api.papacapim.just.pro.br";
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

  Future<User> getMyProfile() async {
    final token = await _getRequiredAuthToken();

    // CORREÇÃO FINAL:
    // Voltando a usar o endpoint '/me' (o mais padrão para "perfil do próprio utilizador")
    // com o cabeçalho 'x-session-token' que sabemos ser o correto.
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {'Content-Type': 'application/json', 'x-session-token': token},
    );

    if (response.statusCode == 200) {
      // Usando o seu user_model.dart original
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça o login novamente.');
    } else {
      throw Exception(
        'Falha ao carregar dados do perfil (Cód: ${response.statusCode})',
      );
    }
  }
}
