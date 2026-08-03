import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final commentProvider = StateNotifierProvider.family<CommentNotifier, CommentState, int>((ref, articleId) {
  final apiService = ref.read(apiServiceProvider);
  return CommentNotifier(apiService, articleId);
});

class CommentState {
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommentNotifier extends StateNotifier<CommentState> {
  final ApiService _apiService;
  final int _articleId;

  CommentNotifier(this._apiService, this._articleId) : super(const CommentState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true);

    try {
      final comments = await _apiService.getCommentsByArticle(_articleId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<bool> addComment(String content) async {
    state = state.copyWith(isLoading: true);

    try {
      final newComment = await _apiService.addComment(_articleId, content);
      state = state.copyWith(
        comments: [newComment, ...state.comments],
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

  Future<bool> deleteComment(int commentId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.deleteComment(commentId);
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
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