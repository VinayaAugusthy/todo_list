## TaskFlow – Todo List App

TaskFlow is a Flutter todo app that uses Firebase for authentication and data storage and follows a layered architecture with `Repositories` and `Bloc` for state management.

---

## Tech Stack

- **Framework**: Flutter (3.38.5 ,Dart SDK `^3.10.4` – compatible with Flutter 3.22+)
- **State management**: `flutter_bloc`
- **Firebase**: `firebase_core`, `firebase_auth`
- **Sign‑in**: `google_sign_in`
- **Networking / backend access**: `http`

---

## Project Structure & Architecture

The app uses a **layered (Clean-inspired) architecture** with clear responsibilities:

---

## Firebase Setup

The project already expects generated Firebase configuration in `lib/firebase_options.dart` and uses constants from `lib/core/constants/firebase_constants.dart`.

### 1. Create a Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com/).
2. Create a **new project** or use an existing one.
3. Add the platforms you need (Android, iOS, Web).

### 2. Enable Authentication

1. In the Firebase console, go to **Build → Authentication → Sign‑in method**.
2. Enable:
   - **Email/Password** (if used)

### 3. Configure Realtime Database (or Firestore)

The project references a Realtime Database URL in `firebase_constants.dart`:

```dart
const String kFirebaseRealtimeDatabaseUrl =
    'https://<your-project-id>.asia-southeast1.firebasedatabase.app';
```

1. In Firebase console, go to **Build → Realtime Database**.
2. Create a database in the desired region (e.g. `asia-southeast1`).
3. Copy the **database URL** and replace the placeholder in `kFirebaseRealtimeDatabaseUrl`.
4. Adjust rules as needed for development.

```
{
"rules": {
  "users": {
    "$uid": {
      ".read": "auth != null && auth.uid == $uid",
      ".write": "auth != null && auth.uid == $uid"
    }
  }
}
}
```

### 4. Generate `firebase_options.dart` with FlutterFire CLI

If `lib/firebase_options.dart` is missing or you are setting up from scratch:

1. Install the FlutterFire CLI (once):

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Log in and configure Firebase for the project:

   ```bash
   flutterfire configure
   ```

   - Select your Firebase project.
   - Select platforms (Android, iOS, Web, macOS, Windows) as needed.
   - This will generate `lib/firebase_options.dart` and corresponding platform configs (`google-services.json`, `GoogleService-Info.plist`, etc.).

---

## Running the App

### 1. Run on an emulator or device

1. Start an Android emulator or connect a physical device.
2. Or, for iOS, open an iOS Simulator (macOS only).
3. Then run:

```bash
flutter run
```

Flutter will build the app and deploy it to the selected device.
