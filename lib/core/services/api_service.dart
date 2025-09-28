import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:papa_capim/core/models/user_model.dart';
import 'package:papa_capim/core/models/post_model.dart';
import 'package:papa_capim/core/services/secure_storage_service.dart';
import 'package:papa_capim/core/models/like_model.dart';
import 'package:papa_capim/core/models/follow_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.papacapim.just.pro.br';
  final SecureStorageService _storageService = SecureStorageService();

  String get baseUrl => _baseUrl;

  Future<String> _getRequiredAuthToken() async {
    final token = await _storageService.readToken();
    if (token == null) {
      throw Exception(
        'Token de autenticação não encontrado. Faça o login novamente.',
      );
    }
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getRequiredAuthToken();
    return {
      'Content-Type': 'application/json',
      'x-session-token': token,
    };
  }

  Future<User> getMyProfile() async {
    final headers = await _getAuthHeaders();
  
    final userLogin = await _storageService.readUserLogin();
    
    if (userLogin == null) {
      throw Exception('Usuário não encontrado no storage. Faça login novamente.');
    }
    
    print('🔍 BUSCANDO PERFIL DO USUÁRIO: $userLogin');
    print('🌐 URL: $_baseUrl/users/$userLogin');
    
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userLogin'),
      headers: headers,
    );

    print(' RESPOSTA DO PERFIL: ${response.statusCode}');
    print('CORPO: ${response.body}');

    if (response.statusCode == 200) {
      print('PERFIL CARREGADO COM SUCESSO');
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada. Faça o login novamente.');
    } else if (response.statusCode == 404) {
      throw Exception('Usuário "$userLogin" não encontrado na API. Verifique se o login está correto.');
    } else {
      throw Exception(
        'Falha ao carregar dados do perfil (Cód: ${response.statusCode})',
      );
    }
  }

  Future<List<Post>> getPosts({bool feed = false, String? search, int page = 1}) async {
    final headers = await _getAuthHeaders();
    
    final params = {'page': page.toString()};
    if (feed) params['feed'] = '1';
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await http.get(
      Uri.parse('$_baseUrl/posts').replace(queryParameters: params),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((postJson) => Post.fromJson(postJson)).toList();
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao buscar postagens: ${response.statusCode}');
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
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao buscar postagens do usuário: ${response.statusCode}');
    }
  }

  Future<Post> createPost(String message) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: headers,
      body: jsonEncode({'post': {'message': message}}),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao criar postagem: ${response.statusCode}');
    }
  }

  Future<Post> createReply(int postId, String message) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/posts/$postId/replies'),
      headers: headers,
      body: jsonEncode({'reply': {'message': message}}),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao responder postagem: ${response.statusCode}');
    }
  }

  Future<void> deletePost(int postId) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$postId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao excluir postagem: ${response.statusCode}');
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
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao curtir postagem: ${response.statusCode}');
    }
  }

  Future<void> unlikePost(int postId, int likeId) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$postId/likes/$likeId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao descurtir postagem: ${response.statusCode}');
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
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao seguir usuário: ${response.statusCode}');
    }
  }

  Future<void> unfollowUser(String login, int followId) async {
    final headers = await _getAuthHeaders();
    
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$login/followers/$followId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao deixar de seguir: ${response.statusCode}');
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
    } else if (response.statusCode == 401) {
      await _storageService.deleteToken();
      throw Exception('Sessão expirada.');
    } else {
      throw Exception('Falha ao buscar seguidores: ${response.statusCode}');
    }
  }

  Future<void> debugApiStatus() async {
    final token = await _storageService.readToken();
    final userLogin = await _storageService.readUserLogin();
    
    print('🔍 DEBUG API SERVICE:');
    print('   Token presente: ${token != null}');
    print('   UserLogin: $userLogin');
    print('   Base URL: $_baseUrl');
    
    if (token != null && userLogin != null) {
      try {
        final headers = await _getAuthHeaders();
        print('   Headers: $headers');
      } catch (e) {
        print('   Erro ao obter headers: $e');
      }
    }
  }
}