import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/recipe_repository.dart';
import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'services/auth_service.dart';
import 'state/auth_session.dart';
import 'state/recipe_store.dart';
import 'theme.dart';

class RecipeBoxApp extends StatelessWidget {
  const RecipeBoxApp({super.key, required this.auth, required this.repository});
  final AuthService auth;
  final RecipeRepository repository;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AuthSession(auth),
    child: MaterialApp(
      title: 'RecipeBox',
      debugShowCheckedModeBanner: false,
      theme: recipeTheme,
      home: _AuthGate(repository: repository),
    ),
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.repository});
  final RecipeRepository repository;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    if (session.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (session.error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to check your session. ${session.error}'),
            ),
          ),
        ),
      );
    }
    final user = session.user;
    if (user == null) {
      return const _SessionNavigator(
        key: ValueKey('public'),
        home: HomeScreen(),
      );
    }
    // A UID change discards both the route stack and the previous recipe store.
    return ChangeNotifierProvider(
      key: ValueKey(user.uid),
      create: (_) => RecipeStore(repository, user.uid),
      child: _SessionNavigator(
        key: ValueKey('private-${user.uid}'),
        home: const ListScreen(),
      ),
    );
  }
}

class _SessionNavigator extends StatefulWidget {
  const _SessionNavigator({super.key, required this.home});
  final Widget home;
  @override
  State<_SessionNavigator> createState() => _SessionNavigatorState();
}

class _SessionNavigatorState extends State<_SessionNavigator> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => NavigatorPopHandler<void>(
    onPopWithResult: (_) => _navigator.currentState!.pop(),
    child: Navigator(
      key: _navigator,
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => widget.home),
    ),
  );
}
