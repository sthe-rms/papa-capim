import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/like_model.dart';
import '../models/follow_model.dart';
import 'secure_storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.papacapim.just.pro.br';
  final SecureStorageService _storageService = SecureStorageService();

  String get baseUrl => _baseUrl;

  Future<String> _getRequiredAuthToken() async {
    final token = await _storageService.readToken();
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getRequiredAuthToken();
    return {'Content-Type': 'application/json', 'x-session-token': token};
  }

  Future<User> getMyProfile() async {
    final headers = await _getAuthHeaders();
    final userLogin = await _storageService.readUserLogin();

    if (userLogin == null) {
      throw Exception('UserLogin não encontrado no storage');
    }

    final encodedLogin = Uri.encodeComponent(userLogin);
    final url = '$_baseUrl/users/$encodedLogin';
    print('[API SERVICE] Fetching profile from: $url');

    final response = await http.get(Uri.parse(url), headers: headers);

    print('[API SERVICE] Profile Response Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Usuário "$userLogin" não encontrado na API');
    } else {
      throw Exception(
        'Erro ${response.statusCode} ao carregar perfil: ${response.body}',
      );
    }
  }

  Future<void> debugStorage() async {
    final token = await _storageService.readToken();
    final userLogin = await _storageService.readUserLogin();

    print('--- DEBUG SECURE STORAGE ---');
    print('Token: $token');
    print('UserLogin: $userLogin');
    print('--------------------------');
  }

  Future<List<Post>> getPosts({
    bool feed = false,
    String? search,
    int page = 1,
  }) async {
    final headers = await _getAuthHeaders();

    final params = {'page': page.toString()};
    if (feed) params['feed'] = '1';
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$_baseUrl/posts').replace(queryParameters: params);
    print('[API SERVICE] Fetching posts from: $uri');

    final response = await http.get(uri, headers: headers);

    print('[API SERVICE] Posts Response Status Code: ${response.statusCode}');
    print('[API SERVICE] Posts Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((postJson) => Post.fromJson(postJson)).toList();
    } else {
      throw Exception('Erro ao buscar postagens: ${response.body}');
    }
  }

  Future<Post> getPostDetails(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar detalhes do post: ${response.body}');
    }
  }

  Future<Post> createPost(String message) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'post': {'message': message},
    });

    print('[API SERVICE] Attempting to create post...');
    print('[API SERVICE] Endpoint: $_baseUrl/posts');
    print('[API SERVICE] Body: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: headers,
      body: body,
    );

    print('[API SERVICE] Create Post Response Status: ${response.statusCode}');
    print('[API SERVICE] Create Post Response Body: ${response.body}');

    if (response.statusCode == 201) {
      print('[API SERVICE] Post created successfully.');
      return Post.fromJson(jsonDecode(response.body));
    } else {
      print('[API SERVICE] Failed to create post.');
      throw Exception('Erro ao criar postagem: ${response.body}');
    }
  }

  Future<Like> likePost(int postId) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/posts/$postId/likes'),
      headers: headers,
    );

    if (response.statusCode == 201) {
      return Like.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao curtir postagem: ${response.body}');
    }
  }

  Future<void> unlikePost(int postId, int likeId) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$postId/likes/$likeId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao descurtir postagem: ${response.body}');
    }
  }

  Future<User> updateProfile(
    String login, {
    String? name,
    String? password,
    String? passwordConfirmation,
  }) async {
    final headers = await _getAuthHeaders();

    final Map<String, dynamic> userData = {};
    if (name != null) userData['name'] = name;
    if (password != null) userData['password'] = password;
    if (passwordConfirmation != null) {
      userData['password_confirmation'] = passwordConfirmation;
    }

    final response = await http.patch(
      Uri.parse('$_baseUrl/users/$login'),
      headers: headers,
      body: jsonEncode({'user': userData}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao atualizar perfil: ${response.body}');
    }
  }

  Future<void> deleteAccount(String login) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$login'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir conta: ${response.body}');
    }
  }

  Future<List<User>> searchUsers(String query, {int page = 1}) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/users?search=$query&page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Erro ao buscar usuários: ${response.body}');
    }
  }

  Future<Follow> followUser(String login) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/users/$login/followers'),
      headers: headers,
    );

    if (response.statusCode == 201) {
      return Follow.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao seguir usuário: ${response.body}');
    }
  }

  Future<void> unfollowUser(String login, int followId) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$login/followers/$followId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao deixar de seguir: ${response.body}');
    }
  }

  Future<List<User>> getUserFollowers(String login) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/users/$login/followers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Erro ao buscar seguidores: ${response.body}');
    }
  }

  Future<List<Post>> getUserPosts(String login, {int page = 1}) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/users/$login/posts?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((postJson) => Post.fromJson(postJson)).toList();
    } else {
      throw Exception('Erro ao buscar postagens do usuário: ${response.body}');
    }
  }

  Future<Post> createReply(int postId, String message) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/posts/$postId/replies'),
      headers: headers,
      body: jsonEncode({
        'reply': {'message': message},
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao responder postagem: ${response.body}');
    }
  }

  Future<List<Post>> getPostReplies(int postId, {int page = 1}) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId/replies?page=$page'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((postJson) => Post.fromJson(postJson)).toList();
    } else {
      throw Exception('Erro ao buscar respostas: ${response.body}');
    }
  }

  Future<void> deletePost(int postId) async {
    final headers = await _getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$postId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir postagem: ${response.body}');
    }
  }

  Future<List<Like>> getPostLikes(int postId) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId/likes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((likeJson) => Like.fromJson(likeJson)).toList();
    } else {
      throw Exception('Erro ao buscar curtidas: ${response.body}');
    }
  }
}
