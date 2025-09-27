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
    // Chama o método para buscar o perfil assim que a página for construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("P E R F I L"),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Center(
        // O Consumer<ProfileProvider> vai reconstruir a UI
        // sempre que o provider notificar uma mudança (ex: dados carregados)
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            // Se estiver carregando, mostra o indicador de progresso
            if (provider.isLoading) {
              return const CircularProgressIndicator();
            }

            // Se houver uma mensagem de erro, a exibe
            if (provider.errorMessage != null) {
              return Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              );
            }

            // Se o usuário for nulo (e não houver erro), mostra uma mensagem padrão
            if (provider.user == null) {
              return const Text(
                "Não foi possível carregar os dados do perfil.",
              );
            }

            // Se tudo deu certo, mostra a UI do perfil com os dados
            return ListView(
              children: [
                const SizedBox(height: 50),
                // Ícone do perfil
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 10),

                // E-mail do usuário
                Text(
                  provider.user!.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 50),

                // Detalhes do usuário
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Meus Detalhes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                // Caixa com o nome de usuário
                MyBioBox(
                  text: provider.user!.name,
                  sectionName: 'Nome de usuário',
                  onPressed: () {
                    // Lógica para editar o nome de usuário aqui
                  },
                ),

                // Caixa com a bio
                MyBioBox(
                  text: 'Bio vazia',
                  sectionName: 'Bio',
                  onPressed: () {
                    // Lógica para editar a bio aqui
                  },
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
