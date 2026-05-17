import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Creator',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    final createdAt = data['createdAt'];
    return AppUser(
      uid: id,
      name: data['name'] as String? ?? 'Creator',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
