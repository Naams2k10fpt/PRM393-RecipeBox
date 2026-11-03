import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import 'recipe_name_key.dart';

const categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
const difficulties = ['Easy', 'Medium', 'Hard'];

String recipeDocumentId(String uid, String name) {
  String hash(String value) => sha256.convert(utf8.encode(value)).toString();
  return '${hash(uid)}_${hash(recipeNameKey(name))}';
}

class RecipeDraft {
  const RecipeDraft({
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.notes = '',
  });

  final String name;
  final String category;
  final String difficulty;
  final int cookTime;
  final int? servings;
  final String notes;

  Map<String, dynamic> toFields() => {
    'name': name.trim(),
    'nameKey': recipeNameKey(name),
    'category': category,
    'difficulty': difficulty,
    'cookTime': cookTime,
    if (servings != null) 'servings': servings,
    'notes': notes,
  };
}

class Recipe {
  const Recipe({required this.id, required this.draft, required this.favorite});

  factory Recipe.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Recipe(
      id: document.id,
      draft: RecipeDraft(
        name: data['name'] as String,
        category: data['category'] as String,
        difficulty: data['difficulty'] as String,
        cookTime: data['cookTime'] as int,
        servings: data['servings'] as int?,
        notes: data['notes'] as String? ?? '',
      ),
      favorite: data['favorite'] as bool,
    );
  }

  final String id;
  final RecipeDraft draft;
  final bool favorite;

  String get name => draft.name;
  String get category => draft.category;
  String get difficulty => draft.difficulty;
  int get cookTime => draft.cookTime;
  int? get servings => draft.servings;
  String get notes => draft.notes;

  Recipe withFavorite(bool value) =>
      Recipe(id: id, draft: draft, favorite: value);
}
