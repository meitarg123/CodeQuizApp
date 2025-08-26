import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_quiz/domain/models/user_progress.dart';
import 'package:code_quiz/domain/repositories/user_progress_repository.dart';

class FirestoreUserProgressRepository implements UserProgressRepository {
  final FirebaseFirestore _db;
  FirestoreUserProgressRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String quizId) =>
      _db.collection('users').doc(uid).collection('progress').doc(quizId);

  
  @override
  // Get user progress for a specific quiz
  Future<UserProgress> getProgress(String uid, String quizId) async {
    final snap = await _doc(uid, quizId).get();
    final data = snap.data();
    final ids = snap.exists
        ? Set<String>.from((data?['completedQuestionIds'] ?? const <String>[]) as List)
        : <String>{};
    final lastIndex = (data != null && data['lastIndex'] is int)
        ? data['lastIndex'] as int
        : 0;
    return UserProgress(quizId: quizId, completedQuestionIds: ids, lastIndex: lastIndex);
  }

  @override
  // Stream of UserProgress that updates in real-time when Firestore changes.
  Stream<UserProgress> watchProgress(String uid, String quizId) {
    return _doc(uid, quizId).snapshots().map((snap) {
      final data = snap.data();
      final ids = snap.exists
          ? Set<String>.from((data?['completedQuestionIds'] ?? const <String>[]) as List)
          : <String>{};
      final lastIndex = (data != null && data['lastIndex'] is int)
          ? data['lastIndex'] as int
          : 0;
      return UserProgress(quizId: quizId, completedQuestionIds: ids, lastIndex: lastIndex);
    });
  }

  @override
  Future<void> setQuestionCompleted(
    String uid,
    String quizId,
    String questionKey,
    bool completed,
  ) async {
    final ref = _doc(uid, quizId);
    await ref.set({
      'completedQuestionIds': completed
          ? FieldValue.arrayUnion([questionKey])   
          : FieldValue.arrayRemove([questionKey]), 
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> setLastIndex(String uid, String quizId, int lastIndex) async {
    await _doc(uid, quizId).set({
      'lastIndex': lastIndex,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
