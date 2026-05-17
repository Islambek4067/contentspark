import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
    : _authService = authService ?? AuthService(),
      _firestoreService = firestoreService ?? FirestoreService() {
    _subscription = _authService.authStateChanges.listen(_handleAuthChange);
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _subscription;

  User? _user;
  AppUser? _profile;
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isReady => _isReady;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> _handleAuthChange(User? user) async {
    _user = user;
    _profile = null;
    if (user != null) {
      await _storeLastUser(user.uid);
      try {
        _profile = await _firestoreService.getUserProfile(user.uid);
      } catch (_) {
        _profile = AppUser.fromFirebaseUser(user);
      }
    } else {
      await _storeLastUser(null);
    }
    _isReady = true;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    return _runAuthCall(
      () => _authService.signInWithEmail(email: email, password: password),
    );
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthCall(
      () => _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthCall(_authService.signInWithGoogle);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthCall(Future<Object?> Function() action) async {
    _setLoading(true);
    try {
      await action();
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _storeLastUser(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (uid == null) {
      await prefs.remove('lastUserId');
    } else {
      await prefs.setString('lastUserId', uid);
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? error.code;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
