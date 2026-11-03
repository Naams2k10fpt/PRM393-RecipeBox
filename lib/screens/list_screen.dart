import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../state/auth_session.dart';
import '../state/recipe_store.dart';
import '../theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_form.dart';
import '../widgets/shared.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  bool _adding = false;
  bool _loggingOut = false;
  bool _filtersOpen = false;
  String? _notice;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await context.read<AuthSession>().logout();
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _favorite(Recipe recipe) async {
    try {
      await context.read<RecipeStore>().toggleFavorite(recipe);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final store = context.watch<RecipeStore>();
    final recipes = store.visibleRecipes;
    final counts = store.categoryCounts(recipes);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu_rounded, size: 23),
              SizedBox(width: 8),
              Text('List'),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _loggingOut ? null : _logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                session.user?.email ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RecipeColors.muted),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (session.notice != null) ...[
                InlineNotice(session.notice!, onDismiss: session.dismissNotice),
                const SizedBox(height: 14),
              ],
              if (_notice != null) ...[
                InlineNotice(
                  _notice!,
                  onDismiss: () => setState(() => _notice = null),
                ),
                const SizedBox(height: 14),
              ],
              if (!_adding)
                FilledButton.icon(
                  onPressed: () => setState(() {
                    _adding = true;
                    _notice = null;
                  }),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Recipe'),
                ),
              if (_adding)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Recipe',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        RecipeForm(
                          submitLabel: 'Add Recipe',
                          onCancel: () => setState(() => _adding = false),
                          onSubmit: (draft) async {
                            await store.add(draft);
                            if (!mounted) return;
                            setState(() {
                              _adding = false;
                              _notice = 'Recipe added';
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted || !_scroll.hasClients) return;
                              _scroll.animateTo(
                                0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => setState(() => _filtersOpen = !_filtersOpen),
                icon: const Icon(Icons.tune_rounded),
                label: Text(_filtersOpen ? 'Hide filters' : 'Filters & search'),
              ),
              if (_filtersOpen)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Filter recipes',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _search.clear();
                                store.clearFilters();
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _search,
                          onChanged: store.setSearch,
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            hintText: 'Name or notes',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final category = DropdownButtonFormField<String>(
                              key: ValueKey('category-${store.category}'),
                              initialValue: store.category,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: ['All', ...categories]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) store.setCategory(value);
                              },
                            );
                            final difficulty = DropdownButtonFormField<String>(
                              key: ValueKey('difficulty-${store.difficulty}'),
                              initialValue: store.difficulty,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Difficulty',
                              ),
                              items: ['All', ...difficulties]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) store.setDifficulty(value);
                              },
                            );
                            if (constraints.maxWidth < 300) {
                              return Column(
                                children: [
                                  category,
                                  const SizedBox(height: 14),
                                  difficulty,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: category),
                                const SizedBox(width: 12),
                                Expanded(child: difficulty),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Favorites only'),
                          value: store.favoritesOnly,
                          onChanged: store.setFavoritesOnly,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: RecipeColors.green,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        Text(
                          'Recipes: ${recipes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Favorites: ${recipes.where((recipe) => recipe.favorite).length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Total time: ${recipes.fold(0, (sum, recipe) => sum + recipe.cookTime)} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (counts.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      for (final count in counts)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  count.key,
                                  style: const TextStyle(
                                    color: Color(0xFFDCE8D8),
                                  ),
                                ),
                              ),
                              Text(
                                '${count.value}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (store.loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (store.error != null)
                InlineNotice(store.error!, error: true)
              else if (recipes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 40,
                          color: RecipeColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Add a recipe or try another filter.',
                          style: TextStyle(color: RecipeColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final recipe in recipes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecipeCard(
                      recipe: recipe,
                      onFavorite: store.pendingFavorites.contains(recipe.id)
                          ? null
                          : () => _favorite(recipe),
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DetailScreen(recipeId: recipe.id),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
