import 'package:flutter/material.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ArticleCard({super.key, required this.article, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.featuredImage != null)
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('${Constants.baseUrl}${article.featuredImage}', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(article.excerpt ?? (article.content.length > 100 ? '${article.content.substring(0, 100)}...' : article.content), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Constants.categoryColors[article.category]?.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(article.categoryLabel, style: TextStyle(fontSize: 10, color: Constants.categoryColors[article.category]))),
                        const SizedBox(width: 8),
                        Icon(Icons.visibility, size: 14, color: Colors.grey[500]), const SizedBox(width: 2), Text('${article.views}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}