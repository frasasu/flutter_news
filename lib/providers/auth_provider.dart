import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final user = await _apiService.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _apiService.login(email, password);
      final user = User.fromJson(data['user']);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''), isLoading: false);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.register(username, email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = const AuthState();
  }
}