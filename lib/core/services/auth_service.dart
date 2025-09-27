import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/services/api_service.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final SecureStorageService _storageService = SecureStorageService();

  AuthService(this._apiService);

  // --- MÉTODO DE LOGIN (CORRIGIDO) ---
  Future<bool> login(String email, String password) async {
    // Agora usa o getter público 'baseUrl'
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _storageService.writeToken(token);
        return true;
      }
    }
    return false;
  }

  // --- MÉTODO DE REGISTRO (ADICIONADO) ---
  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/users'), // Endpoint de registro
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      // 201 Created é o status de sucesso aqui
      // Lança uma exceção com a mensagem de erro da API, se houver
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao registrar.');
    }
  }
}
