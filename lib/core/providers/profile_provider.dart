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
      _user = await _apiService.getMyProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
