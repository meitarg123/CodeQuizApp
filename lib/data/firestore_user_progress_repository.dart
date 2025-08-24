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
  Future<UserProgress> getProgress(String uid, String quizId) async {
    final snap = await _doc(uid, quizId).get();
    final ids = snap.exists
        ? Set<String>.from((snap.data()?['completedQuestionIds'] ?? const <String>[]) as List)
        : <String>{};
    return UserProgress(quizId: quizId, completedQuestionIds: ids);
  }

  @override
  Stream<UserProgress> watchProgress(String uid, String quizId) {
    return _doc(uid, quizId).snapshots().map((snap) {
      final ids = snap.exists
          ? Set<String>.from((snap.data()?['completedQuestionIds'] ?? const <String>[]) as List)
          : <String>{};
      return UserProgress(quizId: quizId, completedQuestionIds: ids);
    });
  }

  @override
  Future<void> setQuestionCompleted(
      String uid, String quizId, String questionId, bool completed) async {
    final ref = _doc(uid, quizId);
    await _db.runTransaction((tx) async {
      final s = await tx.get(ref);
      final current = s.exists
          ? Set<String>.from((s.data()?['completedQuestionIds'] ?? const <String>[]) as List)
          : <String>{};
      completed ? current.add(questionId) : current.remove(questionId);
      tx.set(ref, {
        'completedQuestionIds': current.toList(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
