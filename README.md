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

A document ID joins the lowercase hexadecimal SHA-256 hashes of the UID and
`nameKey` with an underscore. `nameKey` is the trimmed name after Unicode 17.0
default case folding. Firestore Rules verify the key against the display name
and apply the same Unicode code point limits as the form. Existing recipes
without `nameKey` still load, and edits save the current key. Add and rename
transactions check the destination before writing. Renames preserve the
original timestamp and favorite state.

## Local Firebase

```powershell
firebase emulators:start --project demo-recipebox --only auth,firestore
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```
