import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/core/providers/post_detail_provider.dart';
import 'package:papa_capim/core/providers/profile_provider.dart';
import 'package:papa_capim/core/services/api_service.dart';
import 'package:papa_capim/core/services/auth_service.dart';
import 'package:papa_capim/services/auth/login_ou_register.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (context) => FeedProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<PostDetailProvider>(
          create: (context) => PostDetailProvider(context.read<ApiService>()),
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
