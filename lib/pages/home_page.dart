import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/create_post_modal.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/components/user_card.dart';
import 'package:provider/provider.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'userLogin': 'joao123',
      'userName': 'João Silva',
      'message': 'Acabei de entrar no Papacapim! Que plataforma incrível! 🚀',
      'createdAt': '2024-01-15T10:30:00Z',
      'likesCount': 5,
      'isLiked': false,
      'repliesCount': 2,
    },
    {
      'id': 2,
      'userLogin': 'maria89',
      'userName': 'Maria Santos',
      'message': 'Alguém tem dicas para começar com Flutter? Estou adorando!',
      'createdAt': '2024-01-15T09:15:00Z',
      'likesCount': 12,
      'isLiked': true,
      'repliesCount': 5,
    },
    {
      'id': 3,
      'userLogin': 'pedro_dev',
      'userName': 'Pedro Oliveira',
      'message': 'Finalmente terminei meu projeto! 🎉 #flutter #dart',
      'createdAt': '2024-01-14T16:45:00Z',
      'likesCount': 8,
      'isLiked': false,
      'repliesCount': 3,
    },
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'login': 'joao123',
      'name': 'João Silva',
      'isFollowing': false,
      'followersCount': 150,
    },
    {
      'id': 2,
      'login': 'maria89',
      'name': 'Maria Santos',
      'isFollowing': true,
      'followersCount': 89,
    },
    {
      'id': 3,
      'login': 'pedro_dev',
      'name': 'Pedro Oliveira',
      'isFollowing': false,
      'followersCount': 234,
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  void _refreshFeed() {
    setState(() {
      _posts.shuffle();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feed atualizado!'),
        backgroundColor: themeData().colorScheme.primary,
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeData().colorScheme.surface,
      builder: (context) => const CreatePostModal(),
    );
  }

  void _likePost(int postId) {
    setState(() {
      for (var post in _posts) {
        if (post['id'] == postId) {
          post['isLiked'] = !post['isLiked'];
          post['likesCount'] = post['isLiked'] 
              ? post['likesCount'] + 1 
              : post['likesCount'] - 1;
          break;
        }
      }
    });
  }

  void _replyToPost(int postId) {
    print('Responder ao post $postId');
    // TODO: Implementar funcionalidade de resposta
  }

  void _searchUsers(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = _users.where((user) {
          final name = user['name'].toString().toLowerCase();
          final login = user['login'].toString().toLowerCase();
          final searchTerm = query.toLowerCase();
          return name.contains(searchTerm) || login.contains(searchTerm);
        }).toList();
      }
    });
  }

  void _toggleFollow(int userId) {
    setState(() {
      for (var user in _users) {
        if (user['id'] == userId) {
          user['isFollowing'] = !user['isFollowing'];
          user['followersCount'] = user['isFollowing'] 
              ? user['followersCount'] + 1 
              : user['followersCount'] - 1;
          break;
        }
      }
      _searchUsers(_searchController.text); // Atualizar resultados
    });
  }

  // CORREÇÃO: Remover _viewUserProfile ou substituir por navegação para perfil geral
  void _viewUserProfile(Map<String, dynamic> user) {
    // Por enquanto, vamos apenas mostrar um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil de ${user['name']}'),
        backgroundColor: themeData().colorScheme.primary,
      ),
    );
    
    // TODO: Implementar navegação para perfil de outros usuários
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => UserProfilePage(user: user),
    //   ),
    // );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults.clear();
    });
  }

  // ADICIONAR: Buscar usuários da API
  Future<void> _searchUsersFromApi(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final users = await apiService.searchUsers(query);
      
      setState(() {
        _searchResults = users.map((user) => {
          'id': user.id,
          'login': user.login,
          'name': user.name,
          'isFollowing': false, // TODO: Verificar se está seguindo
          'followersCount': 0, // TODO: Buscar contagem de seguidores
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar usuários: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: _isSearching 
            ? _buildSearchField()
            : const Text("P A P A C A P I M"),
        foregroundColor: themeData().colorScheme.primary,
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
        actions: _isSearching 
            ? [
                IconButton(
                  icon: Icon(Icons.close, color: themeData().colorScheme.primary),
                  onPressed: _clearSearch,
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.search, color: themeData().colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: themeData().colorScheme.primary),
                  onPressed: _refreshFeed,
                  tooltip: 'Atualizar feed',
                ),
              ],
      ),
      floatingActionButton: _isSearching ? null : FloatingActionButton(
        onPressed: _showCreatePostModal,
        backgroundColor: themeData().colorScheme.primary,
        child: Icon(Icons.add, color: themeData().colorScheme.surface),
      ),
      body: _isSearching ? _buildSearchResults() : _buildFeed(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (query) {
        _searchUsers(query); // Busca local
        // _searchUsersFromApi(query); // Descomente para buscar da API
      },
      decoration: InputDecoration(
        hintText: 'Buscar usuários...',
        hintStyle: TextStyle(color: themeData().colorScheme.tertiary),
        border: InputBorder.none,
      ),
      style: TextStyle(color: themeData().colorScheme.primary),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: themeData().colorScheme.tertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'Digite para buscar usuários'
                      : 'Nenhum usuário encontrado',
                  style: TextStyle(
                    color: themeData().colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              return UserCard(
                user: user,
                onFollow: () => _toggleFollow(user['id']),
                onTap: () => _viewUserProfile(user),
              );
            },
          );
  }

  Widget _buildFeed() {
    return Column(
      children: [
        // Cabeçalho para criar post
        Container(
          padding: const EdgeInsets.all(16),
          color: themeData().colorScheme.surface,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: themeData().colorScheme.primary,
                child: Icon(Icons.person, color: themeData().colorScheme.surface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showCreatePostModal,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeData().colorScheme.secondary,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: themeData().colorScheme.tertiary,
                      ),
                    ),
                    child: Text(
                      'O que está acontecendo?',
                      style: TextStyle(
                        color: themeData().colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: themeData().colorScheme.tertiary),
      
        // Lista de posts
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshFeed();
            },
            color: themeData().colorScheme.primary,
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  onLike: () => _likePost(post['id']),
                  onReply: () => _replyToPost(post['id']),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}