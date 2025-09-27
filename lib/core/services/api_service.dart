import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/models/user_model.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart'; // <<< IMPORTE O SERVIÇO

class ApiService {
  final String _baseUrl = "https://api.papacapim.just.pro.br";
  final SecureStorageService _storageService =
      SecureStorageService(); // <<< CRIE UMA INSTÂNCIA

  String get baseUrl => _baseUrl;
  // Função modificada para ler o token do armazenamento seguro
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

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
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
