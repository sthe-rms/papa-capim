// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/create_post_modal.dart';
import 'package:papa_capim/themes/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'userLogin': 'Neymarjr',
      'userName': 'JNeymar Jr',
      'message': 'Bom dia, galera!',
      'createdAt': '2024-01-15T10:30:00Z',
      'likesCount': 999,
      'isLiked': false,
      'repliesCount': 296,
    },
    {
      'id': 2,
      'userLogin': 'maria89',
      'userName': 'Maria Santos',
      'message': 'Amor e paz para todos! ✌️',
      'createdAt': '2024-01-15T09:15:00Z',
      'likesCount': 12,
      'isLiked': true,
      'repliesCount': 5,
    },
    {
      'id': 3,
      'userLogin': 'papacapim',
      'userName': 'Papa Capim',
      'message': 'Eu sou a melhor plataforma do Brasil!',
      'createdAt': '2024-01-14T16:45:00Z',
      'likesCount': 668,
      'isLiked': false,
      'repliesCount': 62,
    },
  ];

  void _refreshFeed() {
    setState(() {
      // Simular atualização do feed
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("P A P A C A P I M"),
        foregroundColor: themeData().colorScheme.primary,
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeData().colorScheme.primary),
            onPressed: _refreshFeed,
            tooltip: 'Atualizar feed',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostModal,
        backgroundColor: themeData().colorScheme.primary,
        child: Icon(Icons.add, color: themeData().colorScheme.surface),
      ),
      body: Column(
        children: [
          // Header do Feed
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
          
          // Lista de Posts
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
      ),
    );
  }
}