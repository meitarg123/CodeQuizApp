//create user doc in firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> upsertUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    await ref.set({
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'user',
    }, SetOptions(merge: true));
  }
}
