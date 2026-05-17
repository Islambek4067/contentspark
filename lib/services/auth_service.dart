import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirestoreService? firestoreService})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;
  bool _googleInitialized = false;

  /// Web Client ID from Firebase Console → Authentication → Sign-in method → Google.
  static const String _serverClientId =
      '370624465644-dkeubeiu093mav5sperl2i71uk1gubk1.apps.googleusercontent.com';

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Safely syncs user profile to Firestore; does not throw on failure.
  Future<void> _syncProfile(User user) async {
    try {
      await _firestoreService.upsertUserProfile(user);
    } catch (_) {
      // Firestore may be temporarily unavailable; auth should still succeed.
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _syncProfile(user);
    }
    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      try {
        await user.sendEmailVerification();
      } catch (_) {
        // Email verification may fail on emulator; non-critical.
      }
      await _syncProfile(user);
    }
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await googleSignIn.initialize(
        serverClientId: _serverClientId,
      );
      _googleInitialized = true;
    }

    if (!googleSignIn.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unavailable',
        message: 'Google sign-in is not available on this platform.',
      );
    }

    final account = await googleSignIn.authenticate();
    final authentication = account.authentication;
    if (authentication.idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _syncProfile(user);
    }
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }
}

