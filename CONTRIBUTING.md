# Contributing to FundaHub

Mobile Application Development final project. Follow this guide for ownership, branching, and the “done when” checklist for each teammate.

## Ownership map

| Area | Owner |
|------|--------|
| UI / Figma match, Front end Dev| Frank — complete |
| Firebase Auth × 2 methods | Tifare |
| Opportunities CRUD + detail (Firestore) | Timothy |
| Community / Gov / Training backend | Armel |
| Tests, README, PDF report, demo | Titus |

## Branching

1. Pull latest `main` before starting.
2. Create a feature branch: `feature/<name>-<task>`  
   Examples: `feature/tifare-firebase-auth`, `feature/timothy-opportunities-crud`
3. Open a PR into `main` with a short summary + test notes.
4. Do **not** push secrets (`.env`, `google-services.json` with prod keys unchecked, API keys in source). Prefer FlutterFire / documented setup steps.

## Commit style

Use meaningful messages (match existing history):

- `feat: ...` new behaviour
- `fix: ...` bug fix
- `test: ...` tests
- `docs: ...` README / report
- `chore: ...` tooling / config

Avoid giant “update stuff” commits. Prefer small, reviewable commits.

## Architecture rules

- Keep **BLoC + clean architecture** (feature folders with `data` / `domain` / `presentation`).
- UI already exists for most screens — prefer wiring **repositories / datasources** to Firebase rather than redesigning UI.
- Figma remains the layout source of truth; don’t invent screens that already exist.
- `flutter analyze` must stay clean; run `dart format .` before PRs.

## Rubric reminders (team)

- Flutter UI matching Figma  
- Firebase (Auth + Firestore)  
- BLoC clean architecture  
- Full CRUD  
- Two authentication methods  
- Widget + unit tests  
- SharedPreferences settings  
- Meaningful Git history  
- PDF report + 10–15 min demo video  

---

## Tifare — Firebase Auth (2 methods)

**Branch:** `feature/tifare-firebase-auth`

### Scope
- Wire **Firebase Auth**: email/password + **Google Sign-In**
- Replace local auth mock with real Auth
- Forgot-password flow
- Secure logout / session restore
- Auth **unit tests**

### Touch areas (expected)
- `lib/features/auth/`
- Firebase project config (`firebase_options.dart`, platform setup)
- Login / create account / logout paths

### Done when
- [ ] Create account works against Firebase  
- [ ] Email/password login works  
- [ ] Google Sign-In works (second method)  
- [ ] Logout clears session; cold start restores auth correctly  
- [ ] Forgot password sends reset email  
- [ ] Auth unit tests pass  

### Out of scope
- Opportunity CRUD (Timothy)  
- Community/Gov/Training Firestore (Armel)  

---

## Timothy — Firestore opportunities CRUD

**Branch:** `feature/timothy-opportunities-crud`

### Scope
- Firestore collections for opportunities (+ saved)
- Full **CRUD**: create, read, update, delete
- Opportunity **detail** screen wired to Firestore
- Filters / category results backed by queries
- Opportunity repository **unit tests**

### Touch areas (expected)
- `lib/features/opportunities/`
- Home / Search / Saved consumers of the repository
- New or existing opportunity detail UI

### Done when
- [ ] List opportunities from Firestore (not mock-only)  
- [ ] Detail screen loads a real document  
- [ ] Create / update / delete work  
- [ ] Save/unsave persists per user  
- [ ] Filters / categories use queries  
- [ ] Repository unit tests pass  

### Out of scope
- Auth (Tifare)  
- Community / Gov / Training collections (Armel)  

---

## Armel — Community, government, resources (Firestore)

**Branch:** `feature/armel-firestore-content`

### Scope
- Persist community posts + comments
- Persist government programmes
- Persist training resources (seed + read is OK)
- BLoC/data layers for those features (less UI-only)
- Widget tests for community feed / gov list

### Touch areas (expected)
- `lib/features/community/`
- `lib/features/government/`
- `lib/features/resources/`
- Profile navigation already points at these screens

### Done when
- [ ] Profile → Community shows Firestore posts  
- [ ] Comments create/read against Firestore  
- [ ] Profile → Government Programmes uses Firestore  
- [ ] Profile → Training & Resources uses Firestore (or seeded docs)  
- [ ] Widget tests for community feed and gov list pass  

### Out of scope
- Auth (Tifare)  
- Opportunity CRUD (Timothy)  

---

## Titus — Quality, settings, report & demo

**Branch:** `feature/titus-quality-docs-demo` (plus docs commits as needed)

### Scope
- Broader **unit + widget tests** (auth, home, search, settings)
- Keep `flutter analyze` clean + `dart format`
- Finish SharedPreferences settings (e.g. language)
- README: how to run + Firebase setup
- **PDF report** + **10–15 min demo video** (script + recording)
- Enforce meaningful Git commits / PR checklist for the team

### Touch areas (expected)
- `test/`
- `lib/features/settings/`
- `README.md`
- Report / demo assets (agree folder with team, e.g. `docs/`)

### Done when
- [ ] Meaningful widget + unit coverage for core flows  
- [ ] `flutter analyze` clean; code formatted  
- [ ] Settings persistence complete (SharedPreferences)  
- [ ] README documents clone → Firebase → run  
- [ ] PDF report submitted/ready  
- [ ] Demo video (10–15 min) recorded  

### Out of scope
- Owning Firebase Auth or Opportunities CRUD implementation (review/help OK)  

---

## PR checklist (everyone)

- [ ] Branch is up to date with `main`  
- [ ] Scope matches your section only (or note cross-team deps)  
- [ ] No secrets committed  
- [ ] `flutter analyze` clean  
- [ ] Tests added/updated for your area  
- [ ] Short PR description + how to test  

## Creating GitHub issues

If `gh` is not installed, open issues manually on GitHub using the drafts in [`docs/team-issues/`](docs/team-issues/). Title and body are ready to paste.
