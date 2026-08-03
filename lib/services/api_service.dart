import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../utils/constants.dart';

class ApiService {
  // ============ AUTHENTIFICATION ============

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    String url = '${Constants.baseUrl}/api/auth/register';

      final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de l\'inscription');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    String url = '${Constants.baseUrl}/api/auth/login';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, data['token']);
      await prefs.setString(Constants.userKey, json.encode(data['user']));
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de la connexion');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(Constants.userKey);
    if (userStr != null) {
      return User.fromJson(json.decode(userStr));
    }
    return null;
  }

  // ============ ARTICLES ============

  Future<List<Article>> getArticles({int page = 1, String? category, String? search}) async {
    String url = '${Constants.baseUrl}/api/articles?page=$page&limit=10';
    if (category != null) url += '&category=$category';
    if (search != null) url += '&search=$search';


    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );


    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> articlesJson = data['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

  Future<Article> getArticleBySlug(String slug) async {
    final url = '${Constants.baseUrl}/api/articles/$slug';


    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Article.fromJson(json.decode(response.body));
    } else {
      throw Exception('Article non trouvé');
    }
  }

  Future<Article> createArticle(Article article) async {
    final token = await getToken();
    if (token == null) throw Exception('Non authentifié');

    String url = '${Constants.baseUrl}/api/articles';



    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(article.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Article.fromJson(data['article']);
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée, reconnectez-vous');
    } else if (response.statusCode == 404) {
      throw Exception('API non trouvée. Backend démarré sur ${Constants.baseUrl} ?');
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la création');
      } catch (e) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    }
  }

  Future<Article> updateArticle(int id, Article article) async {
    final token = await getToken();
    if (token == null) throw Exception('Non authentifié');

    final url = '${Constants.baseUrl}/api/articles/$id';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(article.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Article.fromJson(data['article']);
    } else {
      throw Exception('Erreur lors de la mise à jour');
    }
  }

  Future<void> deleteArticle(int id) async {
    final token = await getToken();
    if (token == null) throw Exception('Non authentifié');

    final url = '${Constants.baseUrl}/api/articles/$id';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression');
    }
  }

  // ============ COMMENTAIRES ============

  Future<List<Comment>> getCommentsByArticle(int articleId) async {
    try {
      final url = '${Constants.baseUrl}/api/comments/article/$articleId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Comment> addComment(int articleId, String content) async {
    final token = await getToken();
    if (token == null) throw Exception('Non authentifié');

    final url = '${Constants.baseUrl}/api/comments/article/$articleId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout du commentaire');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final token = await getToken();
    if (token == null) throw Exception('Non authentifié');

    final url = '${Constants.baseUrl}/api/comments/$commentId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}