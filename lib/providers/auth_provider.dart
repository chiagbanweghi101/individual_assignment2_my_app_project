import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService {
    _authSubscription = _authService.authStateChanges().listen(_onAuthChanged);
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSubscription;
  User? _user;
  AppUser? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    _errorMessage = null;
    if (user == null) {
      _profile = null;
    } else {
      await _loadUserProfile();
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      _profile = null;
      return;
    }
    _profile = await _firestoreService.getUserProfile(_user!.uid);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      final createdUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUserProfile(createdUser);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to sign up.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to sign in.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    await _user?.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _user?.reload();
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
