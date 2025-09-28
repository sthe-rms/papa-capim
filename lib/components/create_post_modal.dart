import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  void _createPost() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<FeedProvider>(
        context,
        listen: false,
      ).createPost(_messageController.text.trim());

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar postagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeData().colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criar Postagem',
                  style: TextStyle(
                    color: themeData().colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: themeData().colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'O que está acontecendo?',
                hintStyle: TextStyle(color: themeData().colorScheme.tertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData().colorScheme.tertiary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData().colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: themeData().colorScheme.secondary,
              ),
              style: TextStyle(color: themeData().colorScheme.primary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeData().colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Publicar',
                        style: TextStyle(
                          color: themeData().colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
