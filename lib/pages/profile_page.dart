import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_bio_box.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final profileProvider = Provider.of<ProfileProvider>(
    context,
    listen: false,
  );

  User? user;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      user = await profileProvider.getUserProfile();
    } catch (e) {
      _errorMessage = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mostra um Scaffold vazio enquanto carrega ou se houver erro no carregamento inicial
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ocorreu um erro: $_errorMessage')),
      );
    }

    // 2. Constrói a tela principal quando os dados do usuário já foram carregados
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          user!.name,
        ), // Agora é seguro usar '!', pois já verificamos o loading/erro
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          // Username handle
          Center(
            child: Text(
              '@${user!.name}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          const SizedBox(height: 20),

          // Profile picture
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25), // VÍRGULA CORRIGIDA
              ),
              padding: const EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bio
          MyBioBox(
            // ACESSO AO CAMPO 'BIO' CORRIGIDO
            text: user?.bio ?? 'Nenhuma biografia informada.',
          ),
        ],
      ),
    );
  }
}
