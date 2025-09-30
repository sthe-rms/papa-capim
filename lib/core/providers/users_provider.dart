import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UsersProvider with ChangeNotifier {
  final ApiService _apiService;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  UsersProvider(this._apiService);

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _users = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _apiService.searchUsers(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(String login) async {
    final userIndex = _users.indexWhere((u) => u.login == login);
    if (userIndex == -1) return;

    final originalUser = _users[userIndex];

    // Atualização otimista
    _users[userIndex] = originalUser.copyWith(
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
        } else {
          // Se não tiver o followId, busca o perfil pra pegar
          final userProfile = await _apiService.getUserProfile(login);
          if (userProfile.followId != null) {
            await _apiService.unfollowUser(login, userProfile.followId!);
          } else {
            throw Exception(
              'Não foi possível deixar de seguir: followId não encontrado.',
            );
          }
        }
      } else {
        await _apiService.followUser(login);
      }
      // Recarrega o usuário para ter o followId atualizado
      _users[userIndex] = await _apiService.getUserProfile(login);
      notifyListeners();
    } catch (e) {
      // Reverte em caso de erro
      _users[userIndex] = originalUser;
      notifyListeners();
      throw Exception('Erro ao seguir/deixar de seguir usuário: $e');
    }
  }
}
