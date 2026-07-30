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
