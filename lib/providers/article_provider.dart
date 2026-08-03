import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ArticleNotifier(apiService);
});

class ArticleState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const ArticleState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ArticleState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  List<Article> get publishedArticles {
    return articles.where((a) => a.status == 'published').toList();
  }

  List<Article> get draftArticles {
    return articles.where((a) => a.status == 'draft').toList();
  }
}

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ApiService _apiService;

  ArticleNotifier(this._apiService) : super(const ArticleState());

  Future<void> loadArticles({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(articles: [], currentPage: 1, hasMore: true);
    }

    if (!state.hasMore && !refresh) return;

    state = state.copyWith(isLoading: true);

    try {
      final newArticles = await _apiService.getArticles(page: state.currentPage);

      final updatedArticles = refresh ? newArticles : [...state.articles, ...newArticles];
      final hasMore = newArticles.length == 10;
      final nextPage = hasMore ? state.currentPage + 1 : state.currentPage;

      state = state.copyWith(
        articles: updatedArticles,
        isLoading: false,
        currentPage: nextPage,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<bool> addArticle(Article article) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newArticle = await _apiService.createArticle(article);
      state = state.copyWith(
        articles: [newArticle, ...state.articles],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> updateArticle(int id, Article article) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedArticle = await _apiService.updateArticle(id, article);
      final index = state.articles.indexWhere((a) => a.id == id);
      if (index != -1) {
        final newList = [...state.articles];
        newList[index] = updatedArticle;
        state = state.copyWith(articles: newList, isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> deleteArticle(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.deleteArticle(id);
      state = state.copyWith(
        articles: state.articles.where((a) => a.id != id).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }
}