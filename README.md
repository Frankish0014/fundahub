# FundaHub

Mobile-first Flutter app for young entrepreneurs in Rwanda/Africa to discover funding, government programmes, education resources, and community support.

## Team

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for ownership, branching, and “done when” checklists.

Issue drafts to paste on GitHub: [`docs/team-issues/`](docs/team-issues/).

## Getting started

```bash
flutter pub get
flutter run -d chrome --no-web-resources-cdn
```

For a phone-sized preview in the browser: open DevTools (`F12`) → device toolbar (`Ctrl+Shift+M`).

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

## Firebase authentication setup

Email/password, Google Sign-In, password reset, session restoration, and auth-test setup are documented in [`AUTH_SETUP.md`](AUTH_SETUP.md). Configure Firebase before running the app against a real project.
