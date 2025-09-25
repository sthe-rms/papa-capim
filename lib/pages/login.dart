import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_button.dart';
import 'package:papa_capim/components/my_text_field.dart';
import 'package:papa_capim/core/services/auth_service.dart'; // <<< IMPORTE O AUTH_SERVICE
import 'package:papa_capim/pages/home_page.dart'; // <<< IMPORTE A HOME_PAGE

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final AuthService _authService = AuthService(); // <<< CRIE UMA INSTÂNCIA DO SERVIÇO

  bool _isLoading = false; // Variável para controlar o estado de loading

  // Função de login
  void _login() async {
    // Mostra o indicador de loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o método de login do nosso serviço
      await _authService.login(
        emailController.text,
        senhaController.text,
      );

      // Se o login for bem-sucedido, navega para a HomePage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Se der erro, mostra uma mensagem para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Garante que o loading para, mesmo que dê erro
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (seu código de UI continua o mesmo)
                
                const SizedBox(height: 50),
                Icon(
                  Icons.account_circle,
                  key: const ValueKey(72),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  "Bem-vindo de volta!",
                  style: TextStyle(
                    color: (Theme.of(context).colorScheme.primary),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Esqueceu a senha?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // <<< MODIFICAÇÃO IMPORTANTE AQUI
                // Se estiver carregando, mostra um CircularProgressIndicator, senão, mostra o botão
                _isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(onTap: _login, text: "Entrar"),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Não tem uma conta?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.primary,
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