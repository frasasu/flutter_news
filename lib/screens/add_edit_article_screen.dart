import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/article_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AddEditArticleScreen extends ConsumerStatefulWidget {
  final Article? article;
  const AddEditArticleScreen({super.key, this.article});

  @override
  ConsumerState<AddEditArticleScreen> createState() => _AddEditArticleScreenState();
}

class _AddEditArticleScreenState extends ConsumerState<AddEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  late String _category;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.article?.title ?? '';
    _contentController.text = widget.article?.content ?? '';
    _excerptController.text = widget.article?.excerpt ?? '';
    _category = widget.article?.category ?? 'actualite';
    _status = widget.article?.status ?? 'draft';
  }

  // Fonction pour générer un slug valide
  String _generateSlug(String title) {
    String slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    // Ajouter un timestamp pour éviter les doublons
    slug = '$slug-${DateTime.now().millisecondsSinceEpoch}';

    return slug;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Vérifier si l'utilisateur est connecté
    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.article == null ? 'Nouvel article' : 'Modifier l\'article')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Vous devez être connecté pour créer un article'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Nouvel article' : 'Modifier l\'article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Le titre est requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _excerptController,
                  decoration: const InputDecoration(
                    labelText: 'Résumé (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                  validator: (v) => (v == null || v.isEmpty) ? 'Le contenu est requis' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: Constants.categoryLabels.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('📝 Brouillon')),
                    DropdownMenuItem(value: 'published', child: Text('✅ Publié')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(widget.article == null ? 'Créer l\'article' : 'Modifier l\'article'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final slug = _generateSlug(_titleController.text);

      final article = Article(
        title: _titleController.text,
        slug: slug,
        content: _contentController.text,
        excerpt: _excerptController.text.isEmpty ? null : _excerptController.text,
        category: _category,
        status: _status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        final articleNotifier = ref.read(articleProvider.notifier);
        bool success;

        if (widget.article != null && widget.article!.id != null) {
          success = await articleNotifier.updateArticle(widget.article!.id!, article);
        } else {
          success = await articleNotifier.addArticle(article);
        }

        setState(() => _isLoading = false);

        if (success && mounted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.article == null ? '✅ Article créé avec succès !' : '✅ Article modifié avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            final errorState = ref.read(articleProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorState ?? '❌ Erreur lors de la création'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    super.dispose();
  }
}