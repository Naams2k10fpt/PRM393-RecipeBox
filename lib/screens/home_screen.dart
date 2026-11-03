import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/shared.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  void _open(BuildContext context, bool register) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => AuthScreen(register: register)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
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
            Text(
              'RecipeBox',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _open(context, false),
          child: const Text('Login'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton(
            onPressed: () => _open(context, true),
            child: const Text('Register'),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: PageWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
          children: [
            const Text(
              'YOUR PRIVATE RECIPE COLLECTION',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: RecipeColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            Text('RecipeBox', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 14),
            const Text(
              'Good meals start here.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 29,
                height: 1.2,
                color: RecipeColors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keep the recipes you cook and the dishes you want to try in one place.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: RecipeColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _open(context, true),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start saving recipes'),
            ),
            const SizedBox(height: 26),
            const _Feature(
              Icons.restaurant_menu_rounded,
              'Save your recipes',
              'Keep cooking times, servings and notes together.',
            ),
            const SizedBox(height: 12),
            const _Feature(
              Icons.timer_outlined,
              'Sort by cooking time',
              'Find something quick or plan a meal for later.',
            ),
            const SizedBox(height: 12),
            const _Feature(
              Icons.star_outline_rounded,
              'Mark your favorites',
              'Star the dishes you want to make again.',
            ),
            const SizedBox(height: 24),
            const Text(
              'YOUR RECIPES STAY PRIVATE.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                color: RecipeColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: RecipeColors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: RecipeColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
