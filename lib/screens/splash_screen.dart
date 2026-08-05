import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    Navigator.pushReplacementNamed(
      context,
      isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 80, color: Colors.blue[700]),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Blog News',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}