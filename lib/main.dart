import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/recipe_repository.dart';
import 'services/auth_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<void> _startup = _initialize();
  static const _emulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  static const _host = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: kIsWeb ? '127.0.0.1' : '10.0.2.2',
  );

  Future<void> _initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: _emulators
            ? const FirebaseOptions(
                apiKey: 'AIzaSyDemoKeyForLocalEmulatorOnly000000',
                appId: kIsWeb
                    ? '1:1234567890:web:0123456789abcdef'
                    : '1:1234567890:android:0123456789abcdef',
                messagingSenderId: '1234567890',
                projectId: 'demo-recipebox',
              )
            : DefaultFirebaseOptions.currentPlatform,
      );
      if (_emulators) {
        await FirebaseAuth.instance.useAuthEmulator(_host, 9199);
        FirebaseFirestore.instance.useFirestoreEmulator(_host, 8188);
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError) {
        return RecipeBoxApp(
          auth: FirebaseAuthService(FirebaseAuth.instance),
          repository: FirestoreRecipeRepository(FirebaseFirestore.instance),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RecipeBox',
        theme: recipeTheme,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 56,
                            color: RecipeColors.green,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'RecipeBox could not open',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Check your connection and try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => setState(() {
                              _startup = _initialize();
                            }),
                            child: const Text('Try again'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

