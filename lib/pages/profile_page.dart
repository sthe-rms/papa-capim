import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_bio_box.dart';
import 'package:provider/provider.dart';
import '../core/providers/profile_provider.dart';

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
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface, // Use surface para consistência
        elevation: 0,
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

                // CORREÇÃO: Alterado de 'email' para 'login' para mostrar o dado correto
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
