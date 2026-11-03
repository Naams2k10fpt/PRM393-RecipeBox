import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

class RecipeStore extends ChangeNotifier {
  RecipeStore(this.repository, this.uid) {
    _subscription = repository
        .watchRecipes(uid)
        .listen(
          (value) {
            _recipes = value;
            loading = false;
            error = null;
            notifyListeners();
          },
          onError: (Object exception) {
            loading = false;
            error = exception.toString();
            _recipes = [];
            notifyListeners();
          },
        );
  }

  final RecipeRepository repository;
  final String uid;
  late final StreamSubscription<List<Recipe>> _subscription;
  List<Recipe> _recipes = [];
  final Map<String, bool> _favoriteOverrides = {};
  final Set<String> pendingFavorites = {};
  bool loading = true;
  String? error;
  String category = 'All';
  String difficulty = 'All';
  bool favoritesOnly = false;
  String search = '';

  List<Recipe> get allRecipes => _recipes.map((recipe) {
    final override = _favoriteOverrides[recipe.id];
    return override == null ? recipe : recipe.withFavorite(override);
  }).toList();

  List<Recipe> get visibleRecipes {
    final query = search.trim().toLowerCase();
    final result = allRecipes
        .where(
          (recipe) =>
              (category == 'All' || recipe.category == category) &&
              (difficulty == 'All' || recipe.difficulty == difficulty) &&
              (!favoritesOnly || recipe.favorite) &&
              (query.isEmpty ||
                  recipe.name.toLowerCase().contains(query) ||
                  recipe.notes.toLowerCase().contains(query)),
        )
        .toList();
    result.sort((a, b) {
      final byTime = a.cookTime.compareTo(b.cookTime);
      if (byTime != 0) return byTime;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  List<MapEntry<String, int>> categoryCounts(List<Recipe> visible) {
    final counts = categories
        .map(
          (category) => MapEntry(
            category,
            visible.where((recipe) => recipe.category == category).length,
          ),
        )
        .where((entry) => entry.value > 0)
        .toList();
    counts.sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0
          ? byCount
          : categories.indexOf(a.key).compareTo(categories.indexOf(b.key));
    });
    return counts;
  }

  Recipe? find(String id) {
    for (final recipe in allRecipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setDifficulty(String value) {
    difficulty = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    favoritesOnly = value;
    notifyListeners();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void clearFilters() {
    category = difficulty = 'All';
    favoritesOnly = false;
    search = '';
    notifyListeners();
  }

  Future<String> add(RecipeDraft draft) => repository.add(uid, draft);
  Future<String> save(String id, RecipeDraft draft) =>
      repository.save(uid, id, draft);
  Future<void> delete(String id) => repository.delete(uid, id);

  Future<void> toggleFavorite(Recipe recipe) async {
    if (pendingFavorites.contains(recipe.id)) return;
    pendingFavorites.add(recipe.id);
    _favoriteOverrides[recipe.id] = !recipe.favorite;
    notifyListeners();
    try {
      await repository.setFavorite(uid, recipe.id, !recipe.favorite);
    } finally {
      _favoriteOverrides.remove(recipe.id);
      pendingFavorites.remove(recipe.id);
      if (!_disposed) notifyListeners();
    }
  }

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
