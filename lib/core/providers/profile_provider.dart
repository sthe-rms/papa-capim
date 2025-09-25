import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum ProfileState { Initial, Loading, Loaded, Error }

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  User? get user => _user;

  ProfileState _state = ProfileState.Initial;
  ProfileState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchProfileData() async {
    try {
      _state = ProfileState.Loading;
      notifyListeners(); // Avisa a UI que está carregando

      _user = await _apiService.getMyProfile(); // Chama o serviço

      _state = ProfileState.Loaded;
      notifyListeners(); // Avisa a UI que os dados chegaram
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.Error;
      notifyListeners(); // Avisa a UI que deu erro
    }
  }
}
