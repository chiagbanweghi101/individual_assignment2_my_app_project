import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUser.fromMap(doc.data()!);
  }

  Stream<List<Listing>> watchListings() {
    return _listings
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Listing.fromDoc).toList());
  }

  Stream<List<Listing>> watchListingsByUser(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(Listing.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> createListing(Listing listing) async {
    await _listings.add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    await _listings.doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _listings.doc(listingId).delete();
  }
}
