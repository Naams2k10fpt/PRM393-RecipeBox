import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../state/recipe_store.dart';
import '../theme.dart';
import '../widgets/recipe_form.dart';
import '../widgets/shared.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.recipeId});
  final String recipeId;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String _id = widget.recipeId;
  bool _editing = false;
  bool _deleting = false;
  String? _awaitingId;
  String? _notice;

  Future<void> _favorite(Recipe recipe) async {
    try {
      await context.read<RecipeStore>().toggleFavorite(recipe);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this recipe?'),
        content: const Text(
          'This recipe and its notes will be removed from your collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await context.read<RecipeStore>().delete(_id);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _deleting = false);
        showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecipeStore>();
    final recipe = store.find(_id);
    if (recipe != null) _awaitingId = null;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: SafeArea(
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              if (recipe == null) ...[
                if (_awaitingId != null || _deleting)
                  const Center(child: CircularProgressIndicator())
                else
                  const InlineNotice('This recipe is no longer available.'),
              ] else if (_editing) ...[
                Text(
                  'Edit Recipe',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                RecipeForm(
                  initial: recipe.draft,
                  submitLabel: 'Save',
                  onCancel: () => setState(() => _editing = false),
                  onSubmit: (draft) async {
                    final nextId = await store.save(_id, draft);
                    if (!mounted) return;
                    setState(() {
                      _id = nextId;
                      _awaitingId = nextId;
                      _editing = false;
                      _notice = 'Recipe saved';
                    });
                  },
                ),
              ] else ...[
                if (_notice != null) ...[
                  InlineNotice(
                    _notice!,
                    onDismiss: () => setState(() => _notice = null),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FavoriteButton(
                      favorite: recipe.favorite,
                      onPressed: store.pendingFavorites.contains(recipe.id)
                          ? null
                          : () => _favorite(recipe),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DetailField('Category', recipe.category),
                        _DetailField('Difficulty', recipe.difficulty),
                        _DetailField('Cook time', '${recipe.cookTime} min'),
                        _DetailField(
                          'Servings',
                          recipe.servings?.toString() ?? '—',
                        ),
                        _DetailField(
                          'Notes',
                          recipe.notes.isEmpty ? 'No notes yet' : recipe.notes,
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => setState(() {
                          _editing = true;
                          _notice = null;
                        }),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _deleting ? null : _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RecipeColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    ),
  );
}
