import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/create_post_modal.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/components/user_card.dart';
import 'package:provider/provider.dart';
import '../core/models/post_model.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../components/reply_post_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? _currentUserLogin;

  // Controller para a paginação
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUserAndFeed();
    });

    // Adiciona o listener para o scroll
    _scrollController.addListener(() {
      // Se o usuário chegou ao final da lista, carrega mais posts
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<FeedProvider>(context, listen: false).loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    // Limpa o controller para evitar vazamentos de memória
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentUserAndFeed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentUserLogin = await authService.getCurrentUserLogin();
    if (mounted) {
      Provider.of<FeedProvider>(context, listen: false).fetchFeed();
      setState(() {});
    }
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
    );
  }

  void _replyToPost(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeData().colorScheme.surface,
      builder: (context) => ReplyPostModal(postId: postId),
    );
  }

  void _deletePost(int postId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeData().colorScheme.secondary,
        title: Text(
          'Excluir Postagem',
          style: TextStyle(color: themeData().colorScheme.primary),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta postagem? Esta ação não pode ser desfeita.',
          style: TextStyle(color: themeData().colorScheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: themeData().colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        await feedProvider.deletePost(postId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postagem excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir postagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _search(String query) async {
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
      final posts = await apiService.getPosts(search: query);

      setState(() {
        _searchResults = [...users, ...posts];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleFollow(int userId) {
    // Lógica de seguir/deixar de seguir
  }

  void _viewUserProfile(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil de ${user.name}'),
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
      onChanged: _search,
      decoration: InputDecoration(
        hintText: 'Buscar usuários e posts...',
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
                      ? 'Digite para buscar usuários ou posts'
                      : 'Nenhum resultado encontrado',
                  style: TextStyle(color: themeData().colorScheme.tertiary),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              if (item is User) {
                return UserCard(
                  user: item,
                  onFollow: () => _toggleFollow(item.id),
                  onTap: () => _viewUserProfile(item),
                );
              } else if (item is Post) {
                return PostCard(
                  post: item,
                  onLike: () async {
                    try {
                      await Provider.of<FeedProvider>(
                        context,
                        listen: false,
                      ).toggleLike(item.id);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  onReply: () => _replyToPost(item.id),
                  onDelete: () => _deletePost(item.id),
                  isOwnPost: item.userLogin == _currentUserLogin,
                );
              }
              return const SizedBox.shrink();
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
                "Erro ao carregar o feed: ${provider.errorMessage!}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feed_outlined,
                  size: 64,
                  color: themeData().colorScheme.tertiary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma postagem no feed.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshFeed,
          color: themeData().colorScheme.primary,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.posts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final post = provider.posts[index];
              return PostCard(
                post: post,
                onLike: () async {
                  try {
                    await provider.toggleLike(post.id);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceAll('Exception: ', ''),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                onReply: () => _replyToPost(post.id),
                onDelete: () => _deletePost(post.id),
                isOwnPost: post.userLogin == _currentUserLogin,
              );
            },
          ),
        );
      },
    );
  }
}
