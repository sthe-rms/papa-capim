import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/create_post_modal.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/components/user_card.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Garante que o feed seja carregado quando a página for iniciada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).fetchFeed();
    });
  }

  void _refreshFeed() {
    Provider.of<FeedProvider>(context, listen: false).refreshFeed();
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeData().colorScheme.surface,
      builder: (context) => const CreatePostModal(),
    ); // <--- Correto! Sem .then() recarregando o feed.
  }

  void _likePost(int postId) {
    Provider.of<FeedProvider>(context, listen: false).toggleLike(postId);
  }

  void _replyToPost(int postId) {
    print('Responder ao post $postId');
  }

  void _searchUsers(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

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
        _searchResults = users
            .map(
              (user) => {
                'id': user.id,
                'login': user.login,
                'name': user.name,
                'isFollowing': false,
                'followersCount': 0,
              },
            )
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar usuários: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleFollow(int userId) {
    // Implemente a lógica de seguir/deixar de seguir aqui
  }

  void _viewUserProfile(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil de ${user['name']}'),
        backgroundColor: themeData().colorScheme.primary,
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults.clear();
    });
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
                  icon: Icon(
                    Icons.close,
                    color: themeData().colorScheme.primary,
                  ),
                  onPressed: _clearSearch,
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: themeData().colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: themeData().colorScheme.primary,
                  ),
                  onPressed: _refreshFeed,
                  tooltip: 'Atualizar feed',
                ),
              ],
      ),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
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
      onChanged: _searchUsers,
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
            child: Text(
              _searchController.text.isEmpty
                  ? 'Digite para buscar usuários'
                  : 'Nenhum usuário encontrado',
              style: TextStyle(color: themeData().colorScheme.tertiary),
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
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Ocorreu um erro: ${provider.errorMessage}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.posts.isEmpty) {
          return const Center(
            child: Text("Nenhum post encontrado. Seja o primeiro a postar!"),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshFeed(),
          child: ListView.builder(
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              final post = provider.posts[index];
              return PostCard(
                post: post,
                onLike: () => _likePost(post.id),
                onReply: () => _replyToPost(post.id),
              );
            },
          ),
        );
      },
    );
  }
}
