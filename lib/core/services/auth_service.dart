import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/services/api_service.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final SecureStorageService _storageService = SecureStorageService();

  AuthService(this._apiService);

  Future<bool> login(String email, String password) async {
    final body = jsonEncode({'login': email, 'password': password});
    
    print('🔐 TENTANDO LOGIN: $email');
    print('🌐 URL: ${_apiService.baseUrl}/sessions');
    
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('📡 RESPOSTA DA API: ${response.statusCode}');
    print('📦 CORPO DA RESPOSTA: "${response.body}"');
    print('📦 TAMANHO DA RESPOSTA: ${response.body.length}');

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty && response.body != "{}") {
        try {
          final data = jsonDecode(response.body);
          print('📊 DADOS DECODIFICADOS: $data');
          
          final String? token = data['token'];
          final String? userLogin = data['user_login'];

          print('✅ TOKEN ENCONTRADO: $token');
          print('✅ USER LOGIN ENCONTRADO: $userLogin');

          if (token != null && userLogin != null) {
            await _storageService.writeToken(token);
            await _storageService.writeUserLogin(userLogin);
            
            // VERIFICAÇÃO
            final savedToken = await _storageService.readToken();
            final savedUser = await _storageService.readUserLogin();
            
            if (savedToken == token && savedUser == userLogin) {
              print('🎉 LOGIN BEM-SUCEDIDO!');
              return true;
            } else {
              throw Exception('Falha ao salvar dados no dispositivo');
            }
          } else {

            if (data.containsKey('error') || data.containsKey('message')) {
              throw Exception(data['error'] ?? data['message'] ?? 'Erro desconhecido');
            } else {
              throw Exception('Estrutura da resposta inesperada: $data');
            }
          }
        } catch (e) {
          throw Exception('Erro ao decodificar JSON: $e');
        }
      } else {
        throw Exception('Resposta da API vazia ou inválida');
      }
    }

    String errorMessage = 'Falha no login (Código: ${response.statusCode})';
    
    if (response.statusCode == 401) {
      errorMessage = 'Email ou senha incorretos';
    } else if (response.statusCode == 404) {
      errorMessage = 'Endpoint não encontrado. Verifique a URL da API.';
    } else if (response.statusCode == 500) {
      errorMessage = 'Erro interno do servidor';
    }
    
    if (response.body.isNotEmpty && response.body != "{}") {
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] ?? 
                      errorData['message'] ?? 
                      errorData.toString();
      } catch (e) {
        errorMessage = response.body;
      }
    }
    
    throw Exception(errorMessage);
  }

  Future<bool> register(String name, String email, String password) async {
    final body = jsonEncode({
      'user': {
        'name': name,
        'login': email,
        'password': password,
        'password_confirmation': password,
      },
    });

    print('👤 TENTANDO REGISTRAR: $email');
    print('🌐 URL: ${_apiService.baseUrl}/users');
    
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('📡 RESPOSTA DO REGISTRO: ${response.statusCode}');
    print('📦 CORPO DA RESPOSTA: "${response.body}"');

    if (response.statusCode == 201) {
      print('✅ USUÁRIO REGISTRADO COM SUCESSO!');
      return true;
    } else {
      String errorMessage = 'Falha ao registrar (Código: ${response.statusCode})';
      
      if (response.body.isNotEmpty && response.body != "{}") {
        try {
          final errorData = jsonDecode(response.body);
          var apiMessage = errorData['message'] ?? errorData['error'] ?? errorData['errors'];
          
          if (apiMessage is Map) {
            errorMessage = apiMessage.entries
                .map((e) => '${e.key}: ${e.value is List ? e.value.join(", ") : e.value}')
                .join('\n');
          } else if (apiMessage is String) {
            errorMessage = apiMessage;
          }
        } catch (e) {
          errorMessage = 'Erro ao processar resposta: ${response.body}';
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    print('✅ LOGOUT REALIZADO');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.readToken();
    final userLogin = await _storageService.readUserLogin();
    return token != null && userLogin != null;
  }

  Future<String?> getCurrentUserLogin() async {
    return await _storageService.readUserLogin();
  }
}