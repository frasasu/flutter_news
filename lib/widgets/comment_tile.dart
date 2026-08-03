import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../providers/auth_provider.dart';

class CommentTile extends ConsumerWidget {
  final Comment comment;
  final VoidCallback onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthor = authState.user?.id == comment.userId;
    final isAdmin = authState.user?.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(comment.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const Spacer(),
                if (isAuthor || isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}