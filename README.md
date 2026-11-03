# RecipeBox

A private recipe collection for Android and the web. RecipeBox uses Firebase
Authentication and Firestore. Firebase client options are in
`lib/firebase_options.dart`.

## Run

```powershell
flutter pub get
flutter run -d chrome
```

Use `flutter run -d <android-device-id>` for Android. Build an installable APK
with `flutter build apk --release`. The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`.

For a different Firebase project, register the Android package
`com.prm393.recipebox` and a web app, replace the client options, enable
Email/Password Authentication, and publish `firestore.rules` to the default
Firestore database. Use `firebase deploy --only firestore:rules --project PROJECT_ID`.

## Firestore

Recipes live in the root `recipes` collection. The app queries by the signed-in
user's UID and sorts and filters the matching recipes locally. Rules validate
each write and check ownership. Blank servings are omitted.

A document ID is the lowercase hexadecimal SHA-256 of the UID, an underscore,
and the lowercase hexadecimal SHA-256 of the trimmed, lowercase name. The Add
transaction reads that path before creating it. Renaming moves the recipe
atomically and preserves its original timestamp and favorite state.

Firestore Rules normalize ASCII, Vietnamese and Latin-1 uppercase letters.
Names using uppercase letters outside these ranges may be refused when Dart
and Rules produce different normalized names.

## Local Firebase

```powershell
firebase emulators:start --project demo-recipebox --only auth,firestore
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```
