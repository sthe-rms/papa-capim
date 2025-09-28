import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_bio_box.dart';
import 'package:provider/provider.dart';
import '../core/providers/profile_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import '../pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  //sdhfhasd8fhuasdhuf
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.clearError();
    provider.fetchProfile();
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
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
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

          if (provider.user == null) {
            return const Center(
              child: Text('Nenhum dado de perfil disponível'),
            );
          }

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
                provider.user!.login,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeData().colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'Meus Detalhes',
                  style: TextStyle(color: themeData().colorScheme.tertiary),
                ),
              ),
              MyBioBox(
                text: provider.user!.name,
                sectionName: 'Nome',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
              ),
              MyBioBox(
                text: provider.user!.login,
                sectionName: 'Usuário',
                onPressed: () {},
              ),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }
}
