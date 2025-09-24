import 'package:flutter/material.dart';
import 'package:ok/components/my_button.dart';
import 'package:ok/components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

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
                const SizedBox(height: 50),
                Icon(
                  Icons.account_circle,
                  key: const ValueKey(72),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 25),
                Text(
                  "Vamos criar sua conta!",
                  style: TextStyle(
                    color: (Theme.of(context).colorScheme.primary),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: nameController,
                  hintText: "Digite o nome",
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: "Digite o email",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: senhaController,
                  hintText: "Digite a senha",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmarSenhaController,
                  hintText: "Confirme a senha",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyButton(onTap: () {}, text: "Cadastrar"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Já é um membro?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Faça o login agora.",
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
