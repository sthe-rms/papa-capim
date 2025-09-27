import 'package:papa_capim/core/services/auth_service.dart';
import 'package:papa_capim/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer_tile.dart';
import 'package:papa_capim/pages/settings_page.dart';
import 'package:papa_capim/services/auth/login_ou_register.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();

    // Navega para a tela de login/registro e remove todas as outras telas da pilha
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      (route) => false, // Essa condição remove todas as rotas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: themeData().colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Icon(
                      Icons.person,
                      size: 72,
                      color: themeData().colorScheme.primary,
                    ),
                  ),
                  Divider(color: themeData().colorScheme.secondary),
                  const SizedBox(height: 10),
                  MyDrawerTile(
                    title: "H O M E",
                    icon: Icons.home,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  MyDrawerTile(
                    title: "P E R F I L",
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  MyDrawerTile(
                    title: "C O N F I G U R A Ç Õ E S",
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MyDrawerTile(
                  title: "S A I R",
                  icon: Icons.logout,
                  onTap: () => logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
