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
    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final String? token = data['token'];
        final String? userLogin = data['user_login'];

        if (token != null && userLogin != null) {
          await _storageService.writeToken(token);
          await _storageService.writeUserLogin(userLogin);
          return true;
        }
      }
    }

    String errorMessage = 'Falha no login (Código: ${response.statusCode})';
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        errorMessage = data['message'] ?? response.body;
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

    final response = await http.post(
      Uri.parse('${_apiService.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      String errorMessage =
          'Falha ao registrar (Código: ${response.statusCode})';
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          var apiMessage =
              errorData['message'] ?? errorData['error'] ?? errorData['errors'];
          if (apiMessage is Map) {
            errorMessage = apiMessage.entries
                .map(
                  (e) =>
                      '${e.key} ${e.value is List ? e.value.join(", ") : e.value}',
                )
                .join('\n');
          } else if (apiMessage is String) {
            errorMessage = apiMessage;
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = 'Ocorreu um erro inesperado.';
        }
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
