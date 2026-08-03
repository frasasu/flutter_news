import 'package:flutter/material.dart';

class Constants {
   static const String baseUrl = 'http://localhost:3000';

  static const String apiBaseUrl = '$baseUrl/api';
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String profile = '$baseUrl/api/auth/profile';
  static const String articles = '$baseUrl/api/articles';
  static const String comments = '$baseUrl/api/comments';

  static const Map<String, Color> categoryColors = {
    'actualite': Colors.blue,
    'politique': Colors.purple,
    'sport': Colors.green,
    'culture': Colors.orange,
    'economie': Colors.teal,
    'technologie': Colors.indigo,
  };

  static const Map<String, String> categoryLabels = {
    'actualite': '📰 Actualité',
    'politique': '🏛️ Politique',
    'sport': '⚽ Sport',
    'culture': '🎭 Culture',
    'economie': '💰 Économie',
    'technologie': '📱 Technologie',
  };

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}