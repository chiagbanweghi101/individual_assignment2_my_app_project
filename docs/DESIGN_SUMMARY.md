# Design Summary: Kigali City Services & Places Directory

## 1. Firestore database structure

The app uses two Firestore collections.

**`users`**  
Each document is keyed by the Firebase Auth user UID. There is one document per signed-up user. Fields:

- `uid` (string) – same as the document ID
- `email` (string)
- `displayName` (string)
- `createdAt` (number) – milliseconds since epoch

User profiles are created when a user signs up; only that user can read and write their own document (enforced by security rules).

**`listings`**  
Each document is one place or service. Documents are auto-generated IDs. Fields:

- `name` (string)
- `category` (string) – e.g. Hospital, Restaurant, Café, Park
- `address` (string)
- `contactNumber` (string)
- `description` (string)
- `coordinates` (GeoPoint) – latitude and longitude
- `createdBy` (string) – UID of the user who created the listing
- `createdAt` (Timestamp)

All authenticated users can read listings. Only the user whose UID matches `createdBy` can update or delete a listing. Create is allowed for any authenticated user, and the app always sets `createdBy` to the current user’s UID.

---

## 2. How listings are modeled in the app

In code, a listing is represented by the `Listing` class in `lib/models/listing.dart`. It has the same fields as the Firestore document (id, name, category, address, contactNumber, description, latitude, longitude, createdBy, createdAt). The class has:

- `toMap()` – used when creating or updating a document (writes to Firestore’s GeoPoint and Timestamp types)
- `Listing.fromDoc()` – builds a `Listing` from a Firestore `DocumentSnapshot`

So the Firestore document shape and the in-memory model match; the service layer converts between them.

---

## 3. State management

The app uses **Provider** (no BLoC or Riverpod). The idea is to keep a clear split: UI only talks to providers; providers talk to services; services talk to Firebase.

**Providers**

- **AuthProvider** – holds the current Firebase user, loading and error state, and (when needed) the user profile from Firestore. It calls `AuthService` for sign-in/sign-up/sign-out and `FirestoreService` for the user profile. The root widget (`AppGate`) watches this to decide whether to show login, verify-email, or the main app.
- **ListingProvider** – holds the list of all listings and the list of “my” listings (filtered by `createdBy`). It subscribes to two Firestore streams from `FirestoreService`: `watchListings()` and `watchListingsByUser(uid)`. When the stream emits, the provider updates its lists and calls `notifyListeners()`, so the Directory, My Listings, and Map screens rebuild. The provider also holds search query and category filter and exposes `filteredListings`, which is computed from the full list (no extra Firestore query).
- **SettingsProvider** – holds the notification toggle (in memory only; no Firestore).

**Services**

- **AuthService** – wraps Firebase Auth (createUser, signIn, signOut). Used only by AuthProvider.
- **FirestoreService** – all Firestore access: user profile read/write, and for listings: streams for “all” and “by user”, plus create, update, delete. Used only by AuthProvider and ListingProvider.

No screen or widget calls Firebase or the services directly; they use `context.read<...>()` or `context.watch<...>()` on the providers. So the flow is: Firestore → FirestoreService → ListingProvider (or AuthProvider) → UI.

---

## 4. Navigation structure

The main app is a single `MaterialApp` with `home: AppGate`. AppGate decides which screen to show based on auth and email verification. After login and verification, the home is `HomeShell`, which has a `BottomNavigationBar` with four items:

1. **Directory** – list of all listings, search bar, category dropdown, “Add Listing” in the app bar. Tapping a row opens the detail screen; owners get edit/delete from a menu.
2. **My Listings** – same list UI but backed by `ListingProvider.myListings` (only listings where `createdBy` equals current user).
3. **Map View** – a full-screen map (OpenStreetMap via `flutter_map`) with a marker for each listing; data comes from `ListingProvider.allListings`.
4. **Settings** – shows the current user’s profile (from AuthProvider) and a toggle for location-based notifications (from SettingsProvider), plus a logout button.

Detail screen and the add/edit listing form are pushed on top of the current tab (no separate route names; simple `Navigator.push`).

---

## 5. Map and coordinates

Listings store latitude and longitude in Firestore as a GeoPoint. The detail screen and the Map View use these coordinates to:

- Centre the map and place a marker (via `flutter_map` and OpenStreetMap tiles, as in the implementation reflection).
- Build the “Navigate with Google Maps” URL so the user can open directions in the browser or Maps app.

So “how we build the map” is: read `listing.latitude` and `listing.longitude` from the listing (which came from Firestore via the provider), pass them into the map widget and into the directions URL. The only difference from the original plan is that the embedded map uses OpenStreetMap instead of Google Maps because of the billing issue described in the reflection.

---

## 6. Design trade-offs and technical choices

- **My Listings sort order:** Firestore doesn’t do the sort; the app does it in Dart after receiving the snapshot. That avoided creating a composite index and kept the app working without extra Console setup. For a small number of listings per user, this is fine.
- **Search and filter:** They are done in memory on the list already loaded from Firestore (by name and category). So we don’t need extra Firestore queries or indexes for search; the trade-off is that very large lists would be fully loaded once. For this project size it’s acceptable.
- **Embedded map:** Using OpenStreetMap instead of Google Maps was a practical workaround for the billing error so the app could still show an embedded map and a marker from Firestore coordinates. Navigation still uses Google Maps via the external link.
- **Email verification:** The app blocks access to the main content until the user’s email is verified (AppGate shows VerifyEmailScreen). In development, verification links can be unreliable; the reflection doesn’t depend on that, and the code path for “verified vs not” is still there and can be demonstrated.

This document and the implementation reflection together describe how the project was built and what we encountered along the way.
