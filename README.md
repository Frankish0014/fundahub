# FundaHub

Mobile-first Flutter app for young entrepreneurs in Rwanda/Africa to discover funding, government programmes, education resources, and community support.

## Team

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for ownership, branching, and “done when” checklists.

Issue drafts to paste on GitHub: [`docs/team-issues/`](docs/team-issues/).

## Getting started

1. **Clone and install dependencies**

   ```bash
   git clone https://github.com/Frankish0014/fundahub.git
   cd fundahub
   flutter pub get
   ```

2. **Connect Firebase.** This app requires a real Firebase project (Auth + Firestore) before it will run — see [`AUTH_SETUP.md`](AUTH_SETUP.md) for the full `flutterfire configure` walkthrough. In short:

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. **Run on a physical device or emulator** — not Chrome/web:

   ```bash
   flutter devices        # confirm an Android/iOS device or emulator is attached
   flutter run             # picks the connected device automatically
   ```

   > **Grading requirement:** this is a Mobile Application Development submission — it must run on an Android/iOS emulator or physical device. A web/Chrome build scores **zero** on the assignment rubric, so `flutter run -d chrome` is fine for a quick UI check during development but must never be what's used for the demo video or final testing.

4. **Run the test suite** before committing/submitting:

   ```bash
   flutter analyze
   dart format --output=none --set-exit-if-changed lib test
   flutter test
   ```

## Accounts & testing

Testers should create **their own accounts** (entrepreneur or provider) for day-to-day flows. Use the **Platform Super Admin** credentials below whenever you need to approve/reject listings and announcements.

- Profiles live in Firebase Auth + Firestore (`users/{uid}`).
- Session restores on relaunch; profile edits sync across Home / Profile / provider workspace.
- Protected screens require sign-in.

### Roles & home shells

| Role | Bottom navigation | Experience |
|------|-------------------|------------|
| Entrepreneur / founder / SME | Home · Search · Saved · Notifications · Profile | Discover verified opportunities; Training & Government from Profile |
| NGO / Government Partner | Dashboard · Listings · Inbox · Notifications · Profile | Publish listings & announcements (pending admin review); Community posts |
| **Platform Super Admin** | Review · Catalogue · Status · Notifications · Profile | Approves/rejects **all** provider content before it goes live |

### Platform Super Admin (official account)

This is the real application Super Admin — provisioned automatically into Firebase Auth and Firestore on app start (also used in deployment). It is **not** available as a self-serve signup role.

| Field | Value |
|-------|--------|
| **Email** | `admin@fundahub.app` |
| **Password** | `FundaHub@Admin2026!` |
| **Role** | Platform Admin (Super Admin) |

On **Log In**, enter the email and password above to open the Review workspace.

**Suggested test path:** create a provider account → publish an opportunity → sign out → sign in as Super Admin → Approve/Reject → sign back in as entrepreneur and confirm visibility.

### Content moderation flow

1. **Provider** creates an opportunity → status `pending` (not shown to entrepreneurs).
2. **Super Admin** approves → status `approved` + verified → appears on entrepreneur Home, Search, Saved, and Notifications.
3. **Super Admin** rejects → provider gets an in-app notification; entrepreneurs never see it.
4. Provider announcements follow the same approve/reject gate before public Notifications. Pending approvals also show in the Super Admin **Notifications** tab.

Preferences such as language, theme, text size, and compact mode are saved on the device with SharedPreferences and restored on the next launch.

### Search (entrepreneurs)

On **Search**, entrepreneurs browse **verified** opportunities only.

- Type in the search bar to match **title, organization, type, tags, location, and description** (results update as you type).
- Tap the **filter** (tune) button to narrow by type: **Grants / Accelerators / Scholarships / Competitions**, and optionally **Open only** (hide closed listings).
- Active filters show as chips; clear them from the chip row, the filter sheet, or **Clear Filters** on the no-results screen.
- Pull down to refresh the catalogue.

## Testing

`flutter test` covers:

- **Auth** (`test/features/auth/`) — register/login/logout/password-reset flows and Firebase session restoration, against a fake `AuthRemoteDataSource`.
- **Home** and **Search** blocs (`test/features/home/`, `test/features/search/`) — success/failure states and cross-bloc user sync, with `bloc_test` + `mocktail`.
- **Settings persistence** (`test/core/theme/`, `test/core/locale/`) — theme mode, text scale, compact mode, and language each persist to `SharedPreferences` and survive a simulated relaunch.
- **Community** and **Government** widget tests (`test/features/community/`, `test/features/government/`) — loading/success/error UI states against a mocked repository.

## Firebase security rules

`firestore.rules` (role-based, per collection) and `firebase/storage.rules` (profile photo uploads) are version-controlled in this repo — see the report for the full explanation. Deploy them with:

```bash
firebase deploy --only firestore:rules,storage:rules
```

## Firebase authentication setup

Email/password, Google Sign-In, password reset, session restoration, and auth-test setup are documented in [`AUTH_SETUP.md`](AUTH_SETUP.md). Configure Firebase before running the app against a real project.

### Firebase Android configuration

Each developer must download `google-services.json` from the FundaHub
Firebase project and place it at:

android/app/google-services.json

Contact the Firebase project owner if you do not have project access.

## Building the Android Release APK

FundaHub uses Google Sign-In through Firebase Authentication. The Google OAuth Web Client ID must be included when building the Android release APK.

### Firebase configuration

Ensure the latest Firebase configuration file is located at:

```text
android/app/google-services.json

The filename must be exactly google-services.json.

Build the release APK

Run the following commands from the project root:

flutter clean
flutter pub get
flutter build apk --release --dart-define=GOOGLE_WEB_CLIENT_ID=382670022014-je7evhjqsu7g7c1a93g8lcn71sm88aen.apps.googleusercontent.com

Do not build the APK using only:

flutter build apk --release

Without the GOOGLE_WEB_CLIENT_ID Dart definition, Google Sign-In will not be configured correctly.

The completed APK will be generated at:

build/app/outputs/flutter-apk/app-release.apk
Google Sign-In troubleshooting

If the application displays the following error:

Google sign-in is not configured correctly.
Check the SHA keys and Web client ID in Firebase.

Confirm that:

The complete release build command above was used.
The latest google-services.json file is inside android/app.
The APK signing certificate SHA-1 and SHA-256 fingerprints are registered in Firebase.
Google Sign-In is enabled under Firebase Authentication.
The Android package name is com.fundahub.fundahub.

##Firabase datastore
<img width="1918" height="972" alt="image" src="https://github.com/user-attachments/assets/2d67b444-784f-45a0-8335-1a773f41a20b" />

##Overview of UI
<img width="738" height="417" alt="image" src="https://github.com/user-attachments/assets/b3712962-b12e-4aa5-abd3-7ef315841b66" />
<img width="703" height="417" alt="image" src="https://github.com/user-attachments/assets/ee11f944-b1d1-4490-af0f-974b5051e3b2" />
<img width="663" height="390" alt="image" src="https://github.com/user-attachments/assets/54306637-570c-4bd0-a652-4add060a0cd7" />

##Testing
<img width="533" height="335" alt="image" src="https://github.com/user-attachments/assets/b661f63c-465b-44b1-928d-490f3fda9f06" />






