import '../utils/constants.dart';

class Article {
  final int? id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String? featuredImage;
  final String category;
  final String status;
  final int views;
  final int? authorId;
  final Map<String, dynamic>? author;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    this.featuredImage,
    this.category = 'actualite',
    this.status = 'draft',
    this.views = 0,
    this.authorId,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? 'Sans titre',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      featuredImage: json['featuredImage'],
      category: json['category'] ?? 'actualite',
      status: json['status'] ?? 'draft',
      views: json['views'] ?? 0,
      authorId: json['authorId'],
      author: json['author'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'category': category,
      'status': status,
    };
  }

  String get categoryLabel {
    return Constants.categoryLabels[category] ?? category;
  }

  String get statusLabel {
    return status == 'published' ? ' Publié' : ' Brouillon';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}