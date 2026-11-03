import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Firebase client config for RecipeBox.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => kIsWeb ? web : android;

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyB4qUvKerPuynzCq1bf0wlxXi0sXmyZxFk',
    appId: '1:1081664236838:android:691f13d10570ed293ca5e7',
    messagingSenderId: '1081664236838',
    projectId: 'recipebox-qe190117',
    storageBucket: 'recipebox-qe190117.firebasestorage.app',
  );

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyCH7uUDnaNz4AUCrMcuq5PuqQ0UTXnWAH8',
    appId: '1:1081664236838:web:71e754a3ff7995353ca5e7',
    messagingSenderId: '1081664236838',
    projectId: 'recipebox-qe190117',
    authDomain: 'recipebox-qe190117.firebaseapp.com',
    storageBucket: 'recipebox-qe190117.firebasestorage.app',
  );
}
