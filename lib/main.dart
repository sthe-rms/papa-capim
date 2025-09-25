import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/profile_provider.dart';
import 'package:papa_capim/pages/login.dart';
import 'package:papa_capim/pages/profile_page.dart';
import 'package:papa_capim/services/auth/login_ou_register.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileProvider())],
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
