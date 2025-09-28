import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_bio_box.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:provider/provider.dart';
import '../core/providers/profile_provider.dart';
import 'package:papa_capim/themes/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("P E R F I L"),
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
        foregroundColor: themeData().colorScheme.primary,
      ),
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const CircularProgressIndicator();
            }

            if (provider.errorMessage != null) {
              return Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              );
            }

            if (provider.user == null) {
              return const Text(
                "Não foi possível carregar os dados do perfil.",
              );
            }

            return ListView(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 10),

                Text(
                  provider.user!.login,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Meus Detalhes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                MyBioBox(
                  text: provider.user!.name,
                  sectionName: 'Nome de usuário',
                  onPressed: () {},
                ),

                MyBioBox(
                  text: 'Bio vazia',
                  sectionName: 'Bio',
                  onPressed: () {},
                ),
                const SizedBox(height: 50),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isFollowing = false;
  int _followersCount = 0;
  final List<Map<String, dynamic>> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user['isFollowing'] ?? false;
    _followersCount = widget.user['followersCount'] ?? 0;
    _loadUserPosts();
  }

  void _loadUserPosts() {
    setState(() {
      _userPosts.addAll([
        {
          'id': 1,
          'userLogin': widget.user['login'],
          'userName': widget.user['name'],
          'message': 'Meu primeiro post no Papacapim! 🎉',
          'createdAt': '2024-01-15T14:30:00Z',
          'likesCount': 8,
          'isLiked': false,
          'repliesCount': 2,
        },
        {
          'id': 2,
          'userLogin': widget.user['login'],
          'userName': widget.user['name'],
          'message': 'Estou adorando essa nova rede social! ',
          'createdAt': '2024-01-14T10:15:00Z',
          'likesCount': 15,
          'isLiked': true,
          'repliesCount': 5,
        },
      ]);
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount = _isFollowing ? _followersCount + 1 : _followersCount - 1;
    });
  }

  void _likePost(int postId) {
    setState(() {
      for (var post in _userPosts) {
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
    print('Responder ao post $postId do usuário ${widget.user['name']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      appBar: AppBar(
        title: Text("P E R F I L  •  ${widget.user['login'].toString().toUpperCase()}"),
        foregroundColor: themeData().colorScheme.primary,
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header do Perfil
            Container(
              padding: const EdgeInsets.all(20),
              color: themeData().colorScheme.secondary,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: themeData().colorScheme.primary,
                    child: Text(
                      widget.user['name'].toString().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: themeData().colorScheme.surface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user['name'],
                    style: TextStyle(
                      color: themeData().colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${widget.user['login']}',
                    style: TextStyle(
                      color: themeData().colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Seguidores', _followersCount),
                      _buildStatItem('Seguindo', 45), // Valor fixo para exemplo
                      _buildStatItem('Posts', _userPosts.length),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing
                            ? themeData().colorScheme.tertiary
                            : themeData().colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        _isFollowing ? 'Deixar de Seguir' : 'Seguir',
                        style: TextStyle(
                          color: themeData().colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informações do Perfil
            MyBioBox(
              text: widget.user['name'],
              sectionName: 'Nome',
              onPressed: () {},
            ),
            MyBioBox(
              text: widget.user['login'],
              sectionName: 'Usuário',
              onPressed: () {},
            ),
            MyBioBox(
              text: 'Bio do usuário será exibida aqui...',
              sectionName: 'Bio',
              onPressed: () {},
            ),

            // Posts do Usuário
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
              child: Text(
                'POSTS',
                style: TextStyle(
                  color: themeData().colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._userPosts.map((post) => PostCard(
                  post: post,
                  onLike: () => _likePost(post['id']),
                  onReply: () => _replyToPost(post['id']),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: themeData().colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: themeData().colorScheme.tertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}