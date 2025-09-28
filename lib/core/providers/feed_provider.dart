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
      throw e;
    }
  }

  Future<void> refreshFeed() async {
    await fetchFeed();
  }
}