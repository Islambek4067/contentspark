import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/script_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _scripts =>
      _firestore.collection('scripts');

  Future<void> upsertUserProfile(User user) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get().timeout(const Duration(seconds: 10));
    final profile = AppUser.fromFirebaseUser(user).toMap();

    if (snapshot.exists) {
      await doc.update({
        'name': profile['name'],
        'email': profile['email'],
        'avatarUrl': profile['avatarUrl'],
      }).timeout(const Duration(seconds: 10));
      return;
    }

    await doc.set(profile).timeout(const Duration(seconds: 10));
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get().timeout(const Duration(seconds: 10));
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Stream<List<ScriptModel>> getUserScripts(String userId) {
    return _scripts
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ScriptModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> saveScript(ScriptModel script) async {
    final doc = await _scripts.add(script.toMap()).timeout(const Duration(seconds: 10));
    return doc.id;
  }

  Future<void> updateScript(String scriptId, Map<String, dynamic> data) {
    return _scripts.doc(scriptId).update(data).timeout(const Duration(seconds: 10));
  }

  Future<void> deleteScript(String scriptId) {
    return _scripts.doc(scriptId).delete().timeout(const Duration(seconds: 10));
  }
}
