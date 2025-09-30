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

  Future<void> fetchProfile({String? userLogin}) async {
    _isLoading = true;
    _errorMessage = null;
    // Limpa o usuário anterior para não mostrar dados antigos enquanto carrega
    _user = null;
    notifyListeners();

    try {
      if (userLogin != null) {
        _user = await _apiService.getUserProfile(userLogin);
      } else {
        _user = await _apiService.getMyProfile();
      }
      print('PERFIL CARREGADO: ${_user?.name}');
    } catch (e) {
      _errorMessage = e.toString();
      print('ERRO NO PERFIL: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(String login) async {
    if (_user == null || _user!.login != login) return;

    final originalUser = _user!;

    // Atualização otimista da UI
    _user = originalUser.copyWith(
      isFollowing: !originalUser.isFollowing,
      followersCount: originalUser.isFollowing
          ? originalUser.followersCount - 1
          : originalUser.followersCount + 1,
    );
    notifyListeners();

    try {
      if (originalUser.isFollowing) {
        if (originalUser.followId != null) {
          await _apiService.unfollowUser(login, originalUser.followId!);
          _user = _user!.copyWith(forceFollowIdToNull: true);
        } else {
          throw Exception(
            'Estado inconsistente: Impossível parar de seguir sem um followId.',
          );
        }
      } else {
        final newFollow = await _apiService.followUser(login);
        _user = _user!.copyWith(followId: newFollow.id);
      }
    } catch (e) {
      // Reverte a UI em caso de erro
      _user = originalUser;
      notifyListeners();
      print(
        "### ERRO NA OPERAÇÃO DE SEGUIR/DEIXAR DE SEGUIR (REVERTENDO UI): ${e.toString()} ###",
      );
      throw e; // Lança o erro para a UI poder notificar o usuário
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
