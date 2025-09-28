import 'package:flutter/material.dart';
import 'package:papa_capim/themes/theme.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onFollow;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onFollow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        color: themeData().colorScheme.secondary,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: themeData().colorScheme.primary,
            child: Text(
              user['name'].toString().substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: themeData().colorScheme.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user['name'],
            style: TextStyle(
              color: themeData().colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${user['login']}',
                style: TextStyle(
                  color: themeData().colorScheme.tertiary,
                ),
              ),
              Text(
                '${user['followersCount']} seguidores',
                style: TextStyle(
                  color: themeData().colorScheme.tertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: user['isFollowing']
                  ? themeData().colorScheme.tertiary
                  : themeData().colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              user['isFollowing'] ? 'Seguindo' : 'Seguir',
              style: TextStyle(
                color: themeData().colorScheme.surface,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}