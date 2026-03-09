import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingProvider extends ChangeNotifier {
  ListingProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService {
    _allListingsSubscription = _firestoreService.watchListings().listen((items) {
      _allListings = items;
      notifyListeners();
    });
  }

  final FirestoreService _firestoreService;

  StreamSubscription<List<Listing>>? _allListingsSubscription;
  StreamSubscription<List<Listing>>? _myListingsSubscription;

  String? _currentUserId;
  List<Listing> _allListings = [];
  List<Listing> _myListings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Listing> get allListings => _allListings;
  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Listing> get filteredListings {
    return _allListings.where((listing) {
      final matchesSearch =
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setCurrentUser(String? uid) {
    if (_currentUserId == uid) {
      return;
    }
    _currentUserId = uid;
    _myListingsSubscription?.cancel();
    if (uid == null) {
      _myListings = [];
      notifyListeners();
      return;
    }
    _myListingsSubscription = _firestoreService.watchListingsByUser(uid).listen(
      (items) {
        _myListings = items;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  Future<bool> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    if (_currentUserId == null) {
      _errorMessage = 'You must be logged in.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    try {
      final listing = Listing(
        id: '',
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: _currentUserId!,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createListing(listing);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Failed to create listing.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _setLoading(true);
    try {
      await _firestoreService.updateListing(listing);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update listing.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteListing(String listingId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteListing(listingId);
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Failed to delete listing.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _allListingsSubscription?.cancel();
    _myListingsSubscription?.cancel();
    super.dispose();
  }
}
