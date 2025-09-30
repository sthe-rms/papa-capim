import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_bio_box.dart';
import 'package:papa_capim/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/providers/profile_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import '../pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String? userLogin;
  const ProfilePage({super.key, this.userLogin});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _currentUserLogin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentUserLogin = await authService.getCurrentUserLogin();
    _loadProfile();
  }

  void _loadProfile() {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.clearError();
    provider.fetchProfile(userLogin: widget.userLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      appBar: AppBar(
        title: const Text("P E R F I L"),
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
        foregroundColor: themeData().colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar perfil',
                    style: TextStyle(
                      color: themeData().colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: themeData().colorScheme.tertiary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final user = provider.user!;
          final isOwnProfile = _currentUserLogin == user.login;

          return ListView(
            children: [
              const SizedBox(height: 50),
              Icon(
                Icons.person,
                size: 72,
                color: themeData().colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                user.login,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeData().colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        user.followersCount.toString(),
                        style: TextStyle(
                          color: themeData().colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seguidores',
                        style: TextStyle(
                          color: themeData().colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      Text(
                        user.followingCount.toString(),
                        style: TextStyle(
                          color: themeData().colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seguindo',
                        style: TextStyle(
                          color: themeData().colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isOwnProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: () async {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isFollowing
                          ? themeData().colorScheme.tertiary
                          : themeData().colorScheme.primary,
                      foregroundColor: user.isFollowing
                          ? themeData().colorScheme.primary
                          : themeData().colorScheme.surface,
                    ),
                    child: Text(user.isFollowing ? 'Seguindo' : 'Seguir'),
                  ),
                ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'Detalhes',
                  style: TextStyle(color: themeData().colorScheme.tertiary),
                ),
              ),
              MyBioBox(
                text: user.name,
                sectionName: 'Nome',
                onPressed: isOwnProfile
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ).then((_) => _loadProfile()); // Recarrega após edição
                      }
                    : null, // Desabilita o botão se não for o próprio perfil
              ),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }
}
