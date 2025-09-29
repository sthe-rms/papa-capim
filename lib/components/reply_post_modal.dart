// lib/components/reply_post_modal.dart

import 'package:flutter/material.dart';
import 'package:papa_capim/core/providers/feed_provider.dart';
import 'package:papa_capim/themes/theme.dart';
import 'package:provider/provider.dart';

class ReplyPostModal extends StatefulWidget {
  final int postId;
  const ReplyPostModal({super.key, required this.postId});

  @override
  State<ReplyPostModal> createState() => _ReplyPostModalState();
}

class _ReplyPostModalState extends State<ReplyPostModal> {
  final TextEditingController _messageController = TextEditingController();
  bool _isReplying = false;

  void _createReply() async {
    if (_messageController.text.trim().isEmpty || _isReplying) {
      return;
    }

    setState(() {
      _isReplying = true;
    });

    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    try {
      await feedProvider.createReply(widget.postId, _messageController.text);

      if (mounted) {
        Navigator.pop(context); // Fecha o modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resposta enviada com sucesso!'),
            backgroundColor: themeData().colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar resposta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReplying = false;
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
                  'Responder',
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
                hintText: 'Digite sua resposta...',
                hintStyle: TextStyle(color: themeData().colorScheme.tertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              child: ElevatedButton(
                onPressed: _createReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeData().colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isReplying
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Responder',
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
