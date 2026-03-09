# How to Create 10 Meaningful Commits for Your Repository

Follow these steps **in order** so your commit history shows progressive development (auth → CRUD → search/filter → map → settings and docs).

---

## Before you start

1. Open a terminal in your project root: `c:\Users\LENOVO\Documents\my_app_project`
2. If you **already have commits** (e.g. one big “initial” commit) and want to replace them with 10 new ones:
   ```bash
   git reset --soft HEAD~1
   git reset HEAD
   ```
   (This keeps your files but undoes the last commit and unstages everything.)
3. If the repo is **new** or has no commits yet, just make sure all your files are saved. You will add them in 10 batches below.

---

## The 10 commits

Run these **one block at a time**: first `git add`, then `git commit` with the message shown.

---

### Commit 1 – Project setup and dependencies

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml .metadata .gitignore
git add android/ ios/ linux/ macos/ windows/ web/ test/
git commit -m "chore: add Flutter project with Firebase, Provider, and map dependencies"
```

---

### Commit 2 – Data models

```bash
git add lib/models/
git commit -m "feat: add AppUser and Listing models for Firestore"
```

---

### Commit 3 – Service layer

```bash
git add lib/services/
git commit -m "feat: add AuthService and FirestoreService for Firebase access"
```

---

### Commit 4 – Authentication UI and state

```bash
git add lib/providers/auth_provider.dart lib/screens/auth/
git commit -m "feat: add AuthProvider and auth screens (login, signup, verify email)"
```

---

### Commit 5 – App entry and auth gate

```bash
git add lib/main.dart lib/firebase_options.dart lib/core/
git commit -m "feat: wire Firebase init, AppGate, and theme in main"
```

---

### Commit 6 – Listings state and Firestore streams

```bash
git add lib/providers/listing_provider.dart
git commit -m "feat: add ListingProvider with Firestore streams and CRUD"
```

---

### Commit 7 – Directory and listing card

```bash
git add lib/screens/directory/ lib/widgets/
git commit -m "feat: add Directory screen with search, filter, and listing card"
```

---

### Commit 8 – My Listings, form, detail, and shell

```bash
git add lib/screens/listings/ lib/screens/home/
git commit -m "feat: add My Listings, listing form, detail screen, and bottom nav shell"
```

---

### Commit 9 – Map View and embedded map

```bash
git add lib/screens/map/
git commit -m "feat: add Map View and embedded map on listing detail (OpenStreetMap)"
```

---

### Commit 10 – Settings, theme polish, and docs

```bash
git add lib/screens/settings/ lib/providers/settings_provider.dart
git add docs/ README.md
git commit -m "feat: add Settings screen and notification toggle; add README and docs"
```

---

## After the 10 commits

Check your history:

```bash
git log --oneline
```

You should see 10 commits in this order. Then push to GitHub (create the repo on GitHub first if needed):

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

If you already had a `remote` and `main` branch:

```bash
git push origin main
```

---

## If something is already committed

If a file was committed in an earlier step and a later `git add` doesn’t include it, that’s fine. Only **new** or **modified** files get added each time. If you get “nothing added”, double-check that the paths exist and that those files weren’t already added in a previous commit.

## Optional: add google-services.json

If you want to commit your Firebase Android config (some people don’t, for security):

```bash
git add android/app/google-services.json
git commit --amend --no-edit
```

That adds it to the last commit. Or add it in commit 1 by including it in the first `git add` line.
