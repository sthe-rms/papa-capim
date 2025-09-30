import 'package:flutter/material.dart';
import 'package:papa_capim/core/models/post_model.dart';
import 'package:papa_capim/themes/theme.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback? onTap; // Adicionado
  final bool isOwnPost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    required this.isOwnPost,
    this.onTap, // Adicionado
  });

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 30) return '${difference.inDays}d';
    return '${difference.inDays ~/ 30}mes';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Adicionado
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData().colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: themeData().colorScheme.primary,
                  child: Text(
                    post.userLogin.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: themeData().colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userLogin, // Idealmente, seria o nome do usuário
                        style: TextStyle(
                          color: themeData().colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${post.userLogin}',
                        style: TextStyle(
                          color: themeData().colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(
                    color: themeData().colorScheme.tertiary,
                    fontSize: 12,
                  ),
                ),
                if (isOwnPost)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.withOpacity(0.7),
                      size: 20,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Excluir Postagem',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.message,
              style: TextStyle(
                color: themeData().colorScheme.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked
                        ? Colors.red
                        : themeData().colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                Text(
                  post.likesCount.toString(),
                  style: TextStyle(
                    color: themeData().colorScheme.tertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: onReply,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: themeData().colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                Text(
                  post.replies.length
                      .toString(), // Atualizado para mostrar o número de respostas
                  style: TextStyle(
                    color: themeData().colorScheme.tertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
