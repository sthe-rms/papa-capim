import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_settings_tile.dart';
import 'package:papa_capim/pages/edit_profile_page.dart';
import 'package:papa_capim/themes/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      appBar: AppBar(
        title: const Text("C O N F I G U R A Ç Õ E S"),
        foregroundColor: themeData().colorScheme.primary,
        backgroundColor: themeData().colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          MySettingsTile(
            title: "Editar Perfil",
            action: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
              icon: Icon(Icons.chevron_right, color: themeData().colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}