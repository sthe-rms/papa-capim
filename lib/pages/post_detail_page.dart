import 'package:flutter/material.dart';
import 'package:papa_capim/components/post_card.dart';
import 'package:papa_capim/components/reply_post_modal.dart';
import 'package:papa_capim/core/models/post_model.dart';
import 'package:papa_capim/core/providers/post_detail_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostDetails();
    });
  }

  void _loadPostDetails() {
    Provider.of<PostDetailProvider>(
      context,
      listen: false,
    ).fetchPostDetails(widget.postId);
  }

  void _replyToPost(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeData().colorScheme.surface,
      builder: (context) => ReplyPostModal(postId: postId),
    ).then(
      (_) => _loadPostDetails(),
    ); // Recarrega os detalhes após fechar o modal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData().colorScheme.surface,
      appBar: AppBar(
        title: const Text("Post"),
        backgroundColor: themeData().colorScheme.surface,
        foregroundColor: themeData().colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPostDetails,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Consumer<PostDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.post == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.post == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Erro ao carregar o post: ${provider.errorMessage!}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.post == null) {
            return const Center(child: Text('Post não encontrado.'));
          }

          final post = provider.post!;

          return RefreshIndicator(
            onRefresh: () => provider.fetchPostDetails(widget.postId),
            child: ListView(
              children: [
                PostCard(
                  post: post,
                  onLike: () => provider.toggleLike(post.id),
                  onReply: () => _replyToPost(post.id),
                  onDelete: () {
                    
                  },
                  isOwnPost: false, 
                  onTap: () {}, 
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Respostas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (provider.replies.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhuma resposta ainda.'),
                    ),
                  )
                else
                  ...provider.replies.map(
                    (reply) => PostCard(
                      post: reply,
                      onLike: () => provider.toggleReplyLike(reply.id),
                      onReply: () => _replyToPost(reply.id),
                      onDelete: () {},
                      isOwnPost: false, 
                      onTap: () {},
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
