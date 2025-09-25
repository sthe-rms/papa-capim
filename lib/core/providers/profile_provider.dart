import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  // O Provider agora depende diretamente do ApiService para buscar os dados.
  final ApiService _apiService = ApiService();

  /// Este método busca os dados do perfil na API e retorna um objeto User.
  /// É o equivalente direto ao `databaseProvider.userProfile()` do seu colega.
  Future<User> getUserProfile() async {
    try {
      final user = await _apiService.getMyProfile();
      return user;
    } catch (e) {
      // Em caso de erro, relançamos a exceção para que a tela possa tratá-la.
      print('Erro ao buscar perfil no provider: $e');
      throw Exception('Falha ao carregar o perfil do usuário.');
    }
  }
}
