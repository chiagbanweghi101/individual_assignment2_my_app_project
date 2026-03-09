# Implementation Reflection: Firebase and Flutter Integration

## Overview

This document describes the main issues I ran into while connecting the Kigali Directory app to Firebase (Authentication and Firestore) and how I fixed them. The app is built in Flutter with Provider for state management; all backend calls go through a service layer, and the UI only talks to providers.

---

## Error 1: Blank screen on web – FirebaseOptions cannot be null

**What happened**

When I ran the app in Chrome (`flutter run -d chrome`), the screen stayed blank. In the console I got:

```
FirebaseOptions cannot be null when creating the default app.
```

The stack trace pointed at `firebase_core_web.dart` and the call to `Firebase.initializeApp()`.

**Why it happened**

I had only set up Firebase for Android (with `google-services.json`). On web, the Flutter Firebase SDK does not read that file; it needs a Dart object that holds the web config (API key, project ID, etc.). I was calling `Firebase.initializeApp()` with no arguments, so on web there were no options and the assert failed.

**What I did to fix it**

1. Installed the Firebase CLI and ran `flutterfire configure` (with the project ID) so that it generated `lib/firebase_options.dart` for all platforms, including web.
2. In `main.dart` I changed:

   ```dart
   await Firebase.initializeApp();
   ```

   to:

   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

   and added the import for `firebase_options.dart`.

After that, the web build had the correct config and the app loaded instead of showing a blank screen.

---

## Error 2: Firestore “The query requires an index”

**What happened**

After fixing the web issue, running the app and opening the Directory (or My Listings) sometimes caused a crash with:

```
[cloud_firestore/failed-precondition] The query requires an index.
```

Firebase also showed a long URL to create a composite index in the Firebase Console (for the `listings` collection, on `createdBy` and `createdAt`).

**Why it happened**

In `FirestoreService` I had a query that did two things: filtered by `createdBy` (for “My Listings”) and ordered by `createdAt`. In Firestore, a query that combines a `where` on one field and an `orderBy` on another needs a composite index. I hadn’t created that index yet.

**What I did to fix it**

I had two options: create the index via the link Firebase gave, or change the query so it didn’t need one. I chose to change the query so the app would work immediately without going into the Console.

In `firestore_service.dart`, for `watchListingsByUser`, I removed the `orderBy('createdAt', descending: true)` from the Firestore query and kept only the `where('createdBy', isEqualTo: uid)`. Then I sorted the list in Dart after converting the snapshot to `Listing` objects:

```dart
list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
```

So “My Listings” still appears newest-first, but Firestore no longer needs a composite index. The trade-off is that sorting happens in the app instead of in the database, which is fine for a list that isn’t huge.

---

## Error 3: Theme compile error – CardTheme vs CardThemeData

**What happened**

When I ran the app (e.g. on Chrome), the build failed with:

```
The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.
```

The error was in `lib/core/theme/app_theme.dart` at the line where I set `cardTheme: CardTheme(...)`.

**Why it happened**

In the Flutter version I’m using, `ThemeData.cardTheme` expects a `CardThemeData` instance. I had used `CardTheme`, which is a different type (the theme descriptor class), so the compiler rejected it.

**What I did to fix it**

I changed `CardTheme(` to `CardThemeData(` in `app_theme.dart` and left the rest of the parameters (color, elevation, shape) the same. The project then compiled successfully.

---

## Google Maps billing and use of OpenStreetMap

**What happened**

The assignment asked for an embedded map with a marker and a button to open directions. I intended to use the Google Maps Flutter plugin. On Android that requires a Maps API key; on web it requires the Maps JavaScript API and a web key. In both cases, Google Cloud asks you to enable billing (payment method) for the Maps platform. When I tried to complete the payment step for my account, I got:

```
Billing setup can't be completed. This action couldn't be completed. [OR_BACR2_44]
```

I couldn’t resolve this error from my side (it’s a Google billing/account restriction), so I couldn’t get a valid Google Maps API key.

**What I did instead**

I kept the requirement that the user can open turn-by-turn directions: the “Navigate with Google Maps” button still opens the Google Maps website (or app) with the listing’s coordinates. That only needs a normal URL (`https://www.google.com/maps/dir/?api=1&destination=...`), so it doesn’t need an API key or billing.

For the embedded map on the detail screen and on the Map View tab, I switched to a free solution so the app didn’t depend on Google Maps billing:

- I added the `flutter_map` and `latlong2` packages.
- I replaced the Google Map widget with `FlutterMap` and used OpenStreetMap tiles (`https://tile.openstreetmap.org/...`).
- The marker and the centre of the map still use the listing’s latitude and longitude from Firestore, so the flow “coordinates from Firestore → map” is unchanged; only the tile provider changed.

So: embedded map = OpenStreetMap (no key, no billing); directions = still Google Maps via the external link. I documented this in the design summary and in the README so it’s clear why the embedded map is not Google Maps.

---

## Summary

The main integration issues were: (1) missing web Firebase config, fixed with `flutterfire configure` and `DefaultFirebaseOptions.currentPlatform`; (2) Firestore composite index requirement, avoided by sorting “My Listings” in Dart; (3) theme type mismatch, fixed by using `CardThemeData`; (4) inability to complete Google Maps billing, worked around by using OpenStreetMap for the embedded map while keeping Google Maps for navigation. All of these are reflected in the code and in this document.
