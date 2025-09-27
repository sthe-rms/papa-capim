import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/profile_provider.dart';
import 'package:papa_capim/core/services/api_service.dart';
import 'package:papa_capim/core/services/auth_service.dart'; // Importe o AuthService
import 'package:papa_capim/services/auth/login_ou_register.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        // Registre o AuthService para que ele possa ser usado em outras partes do app
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(context.read<ApiService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: ThemeData.dark(),
    );
  }
}
