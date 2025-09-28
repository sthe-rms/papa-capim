import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Debug: verificar storage primeiro
      await _apiService.debugStorage();
      
      _user = await _apiService.getMyProfile();
      print('✅ PERFIL CARREGADO: ${_user?.name}');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ ERRO NO PERFIL: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}