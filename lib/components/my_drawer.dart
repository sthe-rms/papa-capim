import 'package:papa_capim/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:papa_capim/components/my_drawer_tile.dart';
import 'package:papa_capim/pages/settings_page.dart';
import 'package:papa_capim/themes/theme.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: themeData().colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
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
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
