class Comment {
  final int? id;
  final String content;
  final String status;
  final int? userId;
  final int? articleId;
  final Map<String, dynamic>? user;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.content,
    this.status = 'approved',
    this.userId,
    this.articleId,
    this.user,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      status: json['status'] ?? 'approved',
      userId: json['userId'],
      articleId: json['articleId'],
      user: json['user'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get username => user?['username'] ?? 'Anonyme';
}