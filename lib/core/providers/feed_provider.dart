import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class FeedProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;

  FeedProvider(this._apiService);

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeed() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMorePosts = true;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts(page: _currentPage);
      if (_posts.length < 10) {
        _hasMorePosts = false;
      }
      await _fetchRepliesForPosts(_posts);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchRepliesForPosts(List<Post> posts) async {
    for (var post in posts) {
      if (post.postId == null) {
        try {
          final replies = await _apiService.getPostReplies(post.id);
          post.replies = replies;
        } catch (e) {
          print("Erro ao buscar respostas para o post ${post.id}: $e");
        }
      }
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    try {
      final newPosts = await _apiService.getPosts(page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        await _fetchRepliesForPosts(newPosts);
        _posts.addAll(newPosts);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentPage--; 
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Ao criar um post, simplesmente recarrega o feed para ter a lista mais atual
  Future<void> createPost(String message) async {
    try {
      await _apiService.createPost(message);
      await fetchFeed();
    } catch (e) {
      print("Erro ao criar post no provider: $e");
      throw e;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _apiService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      print("Erro ao deletar post no provider: $e");
      throw e;
    }
  }

  Future<void> createReply(int postId, String message) async {
    try {
      await _apiService.createReply(postId, message);
      await fetchFeed();
    } catch (e) {
      print("Erro ao criar resposta no provider: $e");
      throw e;
    }
  }

  Future<void> toggleLike(int postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final originalPost = _posts[postIndex];

    _posts[postIndex] = originalPost.copyWith(
      isLiked: !originalPost.isLiked,
      likesCount: originalPost.isLiked
          ? originalPost.likesCount - 1
          : originalPost.likesCount + 1,
    );
    notifyListeners();

    try {
      if (originalPost.isLiked) {
        if (originalPost.likeId != null) {
          await _apiService.unlikePost(postId, originalPost.likeId!);
          _posts[postIndex] = _posts[postIndex].copyWith(
            forceLikeIdToNull: true,
          );
        } else {
          throw Exception(
            'Estado inconsistente: Impossível descurtir sem um likeId.',
          );
        }
      } else {
        final newLike = await _apiService.likePost(postId);
        _posts[postIndex] = _posts[postIndex].copyWith(likeId: newLike.id);
      }
    } catch (e) {
      // Reverte a UI em caso de erro
      _posts[postIndex] = originalPost;
      notifyListeners();
      print(
        "### ERRO NA OPERAÇÃO DE LIKE/UNLIKE (REVERTENDO UI): ${e.toString()} ###",
      );
      throw e; // Lança o erro para a UI poder notificar o usuário
    }
  }

  Future<void> refreshFeed() async {
    await fetchFeed();
  }
}
