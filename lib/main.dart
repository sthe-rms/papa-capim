import 'package:flutter/material.dart';
import 'package:ok/pages/register.dart';
import 'package:ok/services/auth/login_ou_register.dart';
import 'package:ok/themes/theme.dart';
import 'package:ok/pages/home_page.dart';
import 'package:ok/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginOrRegister(),
      theme: ThemeData.light(),
    );
  }
}
