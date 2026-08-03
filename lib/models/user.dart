class User {
  final int id;
  final String username;
  final String email;
  final String? profileImage;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}