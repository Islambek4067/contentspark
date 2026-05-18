# ContentSpark

ContentSpark is a Flutter mobile app for generating platform-ready video scripts with Google Gemini. It supports Firebase Authentication, Cloud Firestore script history, and full script CRUD.

## Features

- Firebase Auth with email/password and Google sign-in
- Registration flow sends Firebase email verification
- Firestore `users` and `scripts` collections
- Gemini script generation with hook, body, CTA, and full script
- Saved script list, editable detail view, save, update, and delete
- Session persistence through Firebase Auth state
- Responsive Material 3 UI using the ContentSpark brand palette

## Setup

1. Create a Firebase project and Android app with package `com.contentspark.app`.
2. Replace `lib/firebase_options.dart` with values from `flutterfire configure`, or edit the placeholder values manually.
3. Enable Firebase Authentication providers: Google and Email/Password.
4. Enable Cloud Firestore and create `users` and `scripts` collections.
5. Run with a Gemini key:

```sh
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

## Build

```sh
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release --dart-define=GEMINI_API_KEY=your_api_key_here
```

The release APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Firestore Shape

`users/{uid}`: `uid`, `name`, `email`, `avatarUrl`, `createdAt`

`scripts/{scriptId}`: `userId`, `title`, `topic`, `platform`, `hook`, `body`, `cta`, `fullScript`, `createdAt`
