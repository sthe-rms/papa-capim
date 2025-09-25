import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; // Importe seu modelo

class ApiService {
  final String _baseUrl = "https://api.papacapim.just.pro.br";

  // IMPORTANTE: O token precisa ser obtido após o login e armazenado
  // de forma segura (ex: flutter_secure_storage).
  // Por agora, vamos simular que você já tem o token.
  Future<String> _getAuthToken() async {
    // Lógica para pegar o token salvo no dispositivo
    // Exemplo: final token = await SecureStorage.read('token');
    return 'SEU_TOKEN_DE_AUTENTICACAO_AQUI'; // Substitua pelo token real
  }

  Future<User> getMyProfile() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // A API exige um token de autorização
      },
    );

    if (response.statusCode == 200) {
      // Se a chamada foi bem sucedida, decodifica o JSON e cria um User
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Se a chamada falhou, lança uma exceção.
      throw Exception('Falha ao carregar os dados do perfil.');
    }
  }

  // Você pode adicionar outros métodos aqui: getBirds(), postSighting(), etc.
}
