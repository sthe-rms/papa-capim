import 'package:flutter/material.dart';
import 'package:papa_capim/themes/theme.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;

  const MyDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: themeData().colorScheme.inversePrimary),
      ),
      leading: Icon(icon, color: themeData().colorScheme.primary),
      onTap: onTap,
    );
  }
}
