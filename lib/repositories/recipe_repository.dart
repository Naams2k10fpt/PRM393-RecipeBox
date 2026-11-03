import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class RecipeException implements Exception {
  const RecipeException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class RecipeRepository {
  Stream<List<Recipe>> watchRecipes(String uid);
  Future<String> add(String uid, RecipeDraft draft);
  Future<String> save(String uid, String id, RecipeDraft draft);
  Future<void> setFavorite(String uid, String id, bool favorite);
  Future<void> delete(String uid, String id);
}

class FirestoreRecipeRepository implements RecipeRepository {
  FirestoreRecipeRepository(this.firestore);
  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      firestore.collection('recipes');

  @override
  Stream<List<Recipe>> watchRecipes(String uid) => _recipes
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Recipe.fromDocument).toList());

  @override
  Future<String> add(String uid, RecipeDraft draft) async {
    final id = recipeDocumentId(uid, draft.name);
    final reference = _recipes.doc(id);
    final created = await firestore.runTransaction<bool>((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) {
        return false;
      }
      transaction.set(reference, {
        ...draft.toFields(),
        'id': id,
        'userId': uid,
        'favorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
    // Keep domain errors outside the SDK callback: Web bridges callback
    // exceptions through JavaScript and can lose their original Dart type.
    if (!created) {
      throw const RecipeException('A recipe with this name already exists.');
    }
    return id;
  }

  @override
  Future<String> save(String uid, String id, RecipeDraft draft) async {
    final nextId = recipeDocumentId(uid, draft.name);
    final outcome = await firestore.runTransaction<String>((transaction) async {
      final current = await transaction.get(_recipes.doc(id));
      if (!current.exists || current.data()!['userId'] != uid) {
        return 'unavailable';
      }
      if (nextId != id) {
        final target = await transaction.get(_recipes.doc(nextId));
        if (target.exists) {
          return 'duplicate';
        }
      }
      // A full replacement also removes optional servings cleared in Edit.
      transaction.set(_recipes.doc(nextId), {
        ...draft.toFields(),
        'id': nextId,
        'userId': uid,
        'favorite': current.data()!['favorite'],
        'createdAt': current.data()!['createdAt'],
      });
      if (nextId != id) transaction.delete(_recipes.doc(id));
      return 'saved';
    });
    if (outcome == 'duplicate') {
      throw const RecipeException('A recipe with this name already exists.');
    }
    if (outcome == 'unavailable') {
      throw const RecipeException('This recipe is no longer available.');
    }
    return nextId;
  }

  @override
  Future<void> setFavorite(String uid, String id, bool favorite) =>
      _recipes.doc(id).update({'favorite': favorite});

  @override
  Future<void> delete(String uid, String id) => _recipes.doc(id).delete();
}
