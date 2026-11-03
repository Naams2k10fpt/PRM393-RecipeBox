import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme.dart';
import 'shared.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    required this.onFavorite,
  });
  final Recipe recipe;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: switch (recipe.category) {
                  'Breakfast' => const Color(0xFF576F59),
                  'Lunch' => const Color(0xFFB08053),
                  'Dinner' => const Color(0xFF667987),
                  _ => const Color(0xFF8C7781),
                },
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${recipe.cookTime} min',
                    style: const TextStyle(color: RecipeColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DifficultyBadge(recipe.difficulty),
                      Text(
                        recipe.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: RecipeColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FavoriteButton(favorite: recipe.favorite, onPressed: onFavorite),
          ],
        ),
      ),
    ),
  );
}
