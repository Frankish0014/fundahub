# Tifare — Firebase Authentication Setup

This branch implements the authentication work assigned to Tifare in `CONTRIBUTING.md`:

- Email/password registration
- Email/password login
- Google Sign-In
- Password reset
- Email verification message after registration
- Firebase session restoration after app restart
- Secure logout
- Auth repository unit tests

## 1. Create your feature branch

```bash
git checkout main
git pull origin main
git checkout -b feature/tifare-firebase-auth
```

## 2. Install the new Flutter packages

From the project root, run:

```bash
flutter pub get
```

The project now uses:

- `firebase_core`
- `firebase_auth`
- `google_sign_in`

## 3. Connect FundaHub to Firebase

Install the Firebase and FlutterFire command-line tools if needed:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Create or select the team's Firebase project, then run:

```bash
flutterfire configure
```

Select **Android**. You may also select iOS if the team will demonstrate on an iPhone.

The Android package name in this project is:

```text
com.fundahub.fundahub
```

Make sure the downloaded/generated Android configuration file is located at:

```text
android/app/google-services.json
```

The Gradle Google services plugin has already been added to:

- `android/settings.gradle.kts`
- `android/app/build.gradle.kts`

## 4. Enable both authentication methods

In Firebase Console:

1. Open **Build → Authentication**.
2. Click **Get started**.
3. Open **Sign-in method**.
4. Enable **Email/Password**.
5. Enable **Google** and choose a project support email.
6. Save both providers.

## 5. Add Android SHA fingerprints for Google Sign-In

From the Flutter project, run one of these commands.

On Windows:

```bash
cd android
gradlew signingReport
```

If this downloaded project does not contain `android/gradlew` and `android/gradlew.bat`, restore the missing Flutter platform files first from the project root:

```bash
flutter create .
```

Review the generated platform-file changes before committing so you do not overwrite team customizations.

On macOS/Linux:

```bash
cd android
./gradlew signingReport
```

Copy the **SHA-1** and **SHA-256** values for the `debug` variant.

In Firebase Console:

1. Open **Project settings → Your apps → Android app**.
2. Add both SHA fingerprints.
3. Save.
4. Download a fresh `google-services.json`.
5. Replace the file in `android/app/`.

After enabling Google Sign-In, confirm that `google-services.json` includes a Web OAuth client entry with `client_type: 3`.

If Google Sign-In still reports that a server client ID is missing, copy the **Web client ID** from Google Cloud/Firebase and run the app with:

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Do not use the Android client ID for `GOOGLE_WEB_CLIENT_ID`; use the Web client ID.

## 6. Test the authentication flows

Run on an Android phone or Android emulator with Google Play services:

```bash
flutter run
```

Test these flows:

1. Create an account with a valid full name, email, password of at least 8 characters, and role.
2. Confirm the user appears in **Firebase Authentication → Users**.
3. Check that the verification email is received.
4. Log out from **Settings**.
5. Log in with email/password.
6. Close the app completely and reopen it; the session should be restored.
7. Log out and use **Continue with Google**.
8. Use **Forgot password?** and confirm the reset email is received.
9. Test invalid email, blank password, weak password, and wrong credentials to show polite error messages.

## 7. Run quality checks

```bash
dart format .
flutter analyze
flutter test
```

The authentication repository test file contains five unit tests:

```text
test/features/auth/data/repositories/auth_repository_impl_test.dart
```

## 8. Suggested commits

Make several small commits rather than one large final commit:

```bash
git add pubspec.yaml lib/main.dart android/
git commit -m "chore: configure Firebase authentication dependencies"

git add lib/features/auth/data lib/features/auth/domain
git commit -m "feat: replace local auth mock with Firebase repository"

git add lib/features/auth/presentation lib/injection
git commit -m "feat: add Google sign-in and password reset flows"

git add test/
git commit -m "test: add Firebase auth repository unit tests"

git add AUTH_SETUP.md README.md
git commit -m "docs: add Firebase auth setup and test instructions"
```

Push your branch:

```bash
git push -u origin feature/tifare-firebase-auth
```

## 9. Pull request description

Use this summary in your PR:

```text
## Summary
- Replaced the SharedPreferences login mock with Firebase Authentication
- Added email/password registration and login
- Added Google Sign-In as the second authentication method
- Added password reset and email verification
- Restored authenticated sessions after app restart
- Updated logout to clear the Firebase session while preserving non-sensitive profile preferences for the same UID
- Added auth repository unit tests

## How to test
1. Add the Firebase Android config and enable Email/Password + Google providers
2. Run `flutter pub get`
3. Run `flutter analyze`
4. Run `flutter test`
5. Run the app on Android and test register, logout, login, Google Sign-In, restart, and password reset
```

## Files owned by this auth change

The main changes are limited to Tifare's expected scope:

- `lib/features/auth/`
- `lib/injection/injection.dart`
- `lib/main.dart`
- Firebase Android setup files
- Auth tests
