import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class PostDetailProvider with ChangeNotifier {
  final ApiService _apiService;

  Post? _post;
  List<Post> _replies = [];
  bool _isLoading = false;
  String? _errorMessage;

  PostDetailProvider(this._apiService);

  Post? get post => _post;
  List<Post> get replies => _replies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPostDetails(int postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _post = await _apiService.getPostDetails(postId);
      _replies = await _apiService.getPostReplies(postId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReply(int postId, String message) async {
    try {
      await _apiService.createReply(postId, message);
      await fetchPostDetails(postId); // Recarrega para ver a nova resposta
    } catch (e) {
      print("Erro ao criar resposta no provider: $e");
      throw e;
    }
  }

  Future<void> toggleLike(int postId) async {
    if (_post == null || _post!.id != postId) return;

    final originalPost = _post!;
    _post = originalPost.copyWith(
      isLiked: !originalPost.isLiked,
      likesCount: originalPost.isLiked
          ? originalPost.likesCount - 1
          : originalPost.likesCount + 1,
    );
    notifyListeners();

    try {
      if (originalPost.isLiked) {
        await _apiService.unlikePost(postId, originalPost.likeId!);
      } else {
        final newLike = await _apiService.likePost(postId);
        _post = _post!.copyWith(likeId: newLike.id);
      }
    } catch (e) {
      _post = originalPost;
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleReplyLike(int replyId) async {
    final replyIndex = _replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final originalReply = _replies[replyIndex];
    _replies[replyIndex] = originalReply.copyWith(
      isLiked: !originalReply.isLiked,
      likesCount: originalReply.isLiked
          ? originalReply.likesCount - 1
          : originalReply.likesCount + 1,
    );
    notifyListeners();

    try {
      if (originalReply.isLiked) {
        await _apiService.unlikePost(replyId, originalReply.likeId!);
      } else {
        final newLike = await _apiService.likePost(replyId);
        _replies[replyIndex] = _replies[replyIndex].copyWith(
          likeId: newLike.id,
        );
      }
    } catch (e) {
      _replies[replyIndex] = originalReply;
      notifyListeners();
      throw e;
    }
  }
}
