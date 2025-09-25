import 'package:flutter/material.dart';
import 'package:papa_capim/pages/register.dart';
import 'package:papa_capim/services/auth/login_ou_register.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:papa_capim/pages/home_page.dart';
import 'package:papa_capim/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/profile_provider.dart';

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
