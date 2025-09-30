import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/create_post_modal.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/core/providers/users_provider.dart';
import 'package:papa_capim/pages/post_detail_page.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/components/user_card.dart';
import 'package:provider/provider.dart';
import '../core/models/post_model.dart';
import '../core/services/auth_service.dart';
import '../components/reply_post_modal.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _postResults = [];
  bool _isSearching = false;
  String? _currentUserLogin;
  TabController? _tabController;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUserAndFeed();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<FeedProvider>(context, listen: false).loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _tabController?.dispose();
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

  void _navigateToPostDetail(int postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(postId: postId)),
    );
  }

  void _navigateToProfile(String userLogin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userLogin: userLogin),
      ),
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

  void _searchUsers(String query) {
    Provider.of<UsersProvider>(context, listen: false).searchUsers(query);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _postResults.clear();
      // Limpa também o provider de usuários
      Provider.of<UsersProvider>(context, listen: false).searchUsers('');
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
        bottom: _isSearching
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Usuários'),
                  Tab(text: 'Posts'),
                ],
              )
            : null,
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
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: themeData().colorScheme.tertiary),
        border: InputBorder.none,
      ),
      style: TextStyle(color: themeData().colorScheme.primary),
    );
  }

  Widget _buildSearchResults() {
    return TabBarView(
      controller: _tabController,
      children: [_buildUserResultsList(), _buildPostResultsList()],
    );
  }

  Widget _buildUserResultsList() {
    return Consumer<UsersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }

        if (provider.users.isEmpty) {
          return Center(
            child: Text(
              _searchController.text.isEmpty
                  ? 'Digite para buscar usuários'
                  : 'Nenhum usuário encontrado',
              style: TextStyle(color: themeData().colorScheme.tertiary),
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.users.length,
          itemBuilder: (context, index) {
            final user = provider.users[index];
            // Não mostrar o botão de seguir no próprio perfil
            if (user.login == _currentUserLogin) {
              return UserCard(
                user: user,
                onFollow: () {}, 
                onTap: () => _navigateToProfile(user.login),
              );
            }
            return UserCard(
              user: user,
              onFollow: () async {
                try {
                  await provider.toggleFollow(user.login);
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
              onTap: () => _navigateToProfile(user.login),
            );
          },
        );
      },
    );
  }

  Widget _buildPostResultsList() {
    if (_postResults.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Digite para buscar posts'
              : 'Nenhum post encontrado',
          style: TextStyle(color: themeData().colorScheme.tertiary),
        ),
      );
    }
    return ListView.builder(
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        final post = _postResults[index];
        return PostCard(
          post: post,
          onTap: () => _navigateToPostDetail(post.id),
          onLike: () async {
            try {
              await Provider.of<FeedProvider>(context, listen: false)
                  .toggleLike(post.id);
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 64),
                SizedBox(height: 16),
                Text('Nenhuma postagem no feed.'),
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
                onTap: () => _navigateToPostDetail(post.id),
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
