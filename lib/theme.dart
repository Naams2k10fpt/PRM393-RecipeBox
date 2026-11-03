import 'package:flutter/material.dart';

class RecipeColors {
  static const green = Color(0xFF254C3B);
  static const ink = Color(0xFF25382F);
  static const paper = Color(0xFFF7F5EF);
  static const muted = Color(0xFF68766C);
  static const line = Color(0xFFDFE4D9);
  static const gold = Color(0xFFB5802D);
}

final recipeTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: RecipeColors.paper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: RecipeColors.green,
    primary: RecipeColors.green,
    surface: const Color(0xFFFFFEFA),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'serif',
      fontSize: 42,
      fontWeight: FontWeight.w700,
      color: RecipeColors.ink,
      height: 1.12,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'serif',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: RecipeColors.ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'serif',
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: RecipeColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: RecipeColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: RecipeColors.ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: RecipeColors.ink, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: RecipeColors.ink, height: 1.45),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: RecipeColors.paper,
    foregroundColor: RecipeColors.ink,
    centerTitle: false,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: RecipeColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: RecipeColors.line),
    ),
    errorMaxLines: 3,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: RecipeColors.line),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFFEFA),
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: RecipeColors.line),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);
