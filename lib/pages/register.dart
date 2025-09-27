import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_button.dart';
import 'package:papa_capim/components/my_text_field.dart';
import 'package:papa_capim/core/services/auth_service.dart';
import 'package:papa_capim/pages/home_page.dart';
import 'package:provider/provider.dart';

// <<< 1. Nomes das classes alterados para RegisterPage >>>
class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // <<< 2. Adicionados controllers para nome e confirmação de senha >>>
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();

  bool _isLoading = false;

  // <<< 3. Criada a nova função _register() >>>
  void _register() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Validação inicial para verificar se as senhas são iguais
    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("As senhas não coincidem!"),
          backgroundColor: Colors.red,
        ),
      );
      return; // Interrompe a função se as senhas forem diferentes
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o método de registro do nosso serviço
      await authService.register(
        nomeController.text,
        emailController.text,
        senhaController.text,
      );

      // Se o registro for bem-sucedido, navega para a HomePage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              // Evita que o teclado cubra os campos
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // <<< 4. Ícone e textos da UI atualizados para registro >>>
                  Icon(
                    Icons.person_add,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Crie sua conta",
                    style: TextStyle(
                      color: (Theme.of(context).colorScheme.primary),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // <<< 5. Adicionados os novos campos de texto >>>
                  MyTextField(
                    controller: nomeController,
                    hintText: "Nome",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: senhaController,
                    hintText: "Senha",
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: confirmarSenhaController,
                    hintText: "Confirmar Senha",
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  // <<< 6. Botão agora chama _register e tem o texto "Registrar" >>>
                  _isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(onTap: _register, text: "Registrar"),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // <<< 7. Link inferior atualizado para "Faça o login" >>>
                      Text(
                        "Já tem uma conta?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Faça o login",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
