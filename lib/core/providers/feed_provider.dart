import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class FeedProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  FeedProvider(this._apiService);

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeed({bool feed = false, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts(feed: feed, search: search);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String message) async {
    try {
      final newPost = await _apiService.createPost(message);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> refreshFeed() async {
    await fetchFeed();
  }

  // Lógica de like/unlike refatorada para maior confiabilidade
  Future<void> toggleLike(int postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.isLiked ?? false;

    // Removemos a atualização otimista daqui para garantir consistência

    try {
      if (isLiked) {
        // --- Processo para DESCURTIR ---
        final likeId = post.likeId;
        if (likeId != null) {
          await _apiService.unlikePost(postId, likeId);
          // Atualiza o post local APÓS o sucesso da API
          _posts[postIndex] = Post(
            id: post.id,
            userLogin: post.userLogin,
            message: post.message,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            likesCount: (post.likesCount ?? 1) - 1,
            isLiked: false,
            likeId: null, // Remove o ID do like
          );
        }
      } else {
        // --- Processo para CURTIR ---
        final newLike = await _apiService.likePost(postId);
        // Atualiza o post local APÓS o sucesso da API
        _posts[postIndex] = Post(
          id: post.id,
          userLogin: post.userLogin,
          message: post.message,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          likesCount: (post.likesCount ?? 0) + 1,
          isLiked: true,
          likeId: newLike.id, // Armazena o novo ID do like!
        );
      }
      notifyListeners(); // Notifica a UI sobre a mudança
    } catch (e) {
      _errorMessage = "Erro ao processar a curtida: ${e.toString()}";
      notifyListeners();
    }
  }
}
