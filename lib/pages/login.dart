import 'package:flutter/material.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/components/my_button.dart';
import 'package:papa_capim/components/my_text_field.dart';
import 'package:papa_capim/core/services/auth_service.dart';
import 'package:papa_capim/pages/home_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  // Variável para controlar o estado de loading
  bool _isLoading = false;

  // Função de login corrigida
  void login(BuildContext context) async {
    // Pega o AuthService que foi registrado no main.dart
    final authService = Provider.of<AuthService>(context, listen: false);

    // Inicia o loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Tenta fazer o login usando o controller correto
      bool success = await authService.login(
        emailController.text,
        senhaController.text,
      );

      // Se o login for bem-sucedido, navega para a HomePage
      if (mounted && success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (mounted) {
        // Mostra um erro se o login falhar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha inválidos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Mostra um erro genérico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Para o loading, independentemente do resultado
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
      backgroundColor: themeData().colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.account_circle,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  "Bem-vindo de volta!",
                  // CORREÇÃO: O fontSize foi colocado dentro do TextStyle()
                  style: TextStyle(
                    color: themeData().colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: "Digite o email...",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: senhaController,
                  hintText: "Digite a senha...",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // CORREÇÃO: Removido o 'const' para permitir a função themeData()
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Esqueceu a senha?",
                    style: TextStyle(
                      color: themeData().colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: () => login(context), text: "Entrar"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Não tem uma conta?",
                      style: TextStyle(
                        color: themeData().colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Registre-se",
                        style: TextStyle(
                          color: themeData().colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
    );
  }
}
