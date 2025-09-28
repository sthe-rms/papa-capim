import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  PostProvider(this._apiService);

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts({bool feed = false, String? search}) async {
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

  Future<void> deletePost(int postId) async {
    try {
      await _apiService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleLike(int postId, bool isCurrentlyLiked, int? likeId) async {
    try {
      if (isCurrentlyLiked && likeId != null) {
        await _apiService.unlikePost(postId, likeId);
      } else {
        await _apiService.likePost(postId);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e;
    }
  }
}