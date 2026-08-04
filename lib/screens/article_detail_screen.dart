import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final commentState = ref.watch(commentProvider(widget.article.id!));
    final commentNotifier = ref.read(commentProvider(widget.article.id!).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.article.featuredImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${Constants.baseUrl}${widget.article.featuredImage}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(widget.article.categoryLabel),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(widget.article.statusLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.article.views} vues'),
                      const SizedBox(width: 16),
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(widget.article.author?['username'] ?? 'Anonyme'),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(widget.article.formattedDate),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.article.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Commentaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (commentState.isLoading && commentState.comments.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (commentState.comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Aucun commentaire',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentState.comments.length,
                      itemBuilder: (context, index) {
                        final comment = commentState.comments[index];
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
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      comment.username,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (isAuthor || isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        onPressed: () => commentNotifier.deleteComment(comment.id!),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(comment.content),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (authState.isAuthenticated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un commentaire...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: commentState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.blue),
                    onPressed: commentState.isLoading
                        ? null
                        : () async {
                            if (_commentController.text.isNotEmpty) {
                              final success = await commentNotifier.addComment(_commentController.text);
                              if (success) {
                                _commentController.clear();
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}