// lib/data/firestore_quiz_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_quiz/domain/repositories/quiz_repository.dart';
import 'package:code_quiz/domain/models/quiz.dart';

class FirestoreQuizRepository implements QuizRepository {
  final FirebaseFirestore _db; // Firestore instance

  FirestoreQuizRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<Quiz>> getAllQuizzes() async {
    final quizzesSnap = await _db
        .collection('quizzes')
        .where('isPublished', isEqualTo: true)
        .get();

    final quizzes = await Future.wait(quizzesSnap.docs.map((qDoc) async {
      final qData = qDoc.data();

      // Fetching questions as JSON
      final questionsSnap = await _db
          .collection('quizzes')
          .doc(qDoc.id)
          .collection('questions')
          .get();

      final questionsJson = questionsSnap.docs.map((d) {
        final m = d.data();
        return {
          'id': (m['id'] as String?) ?? d.id,
          'text': (m['text'] as String?) ?? '',
          'options': List<String>.from(
            (m['options'] as List).map((e) => e.toString()),
          ),
          'correctIndex': (m['correctIndex'] as num).toInt(),
          'explanation': m['explanation'] as String?,
        };
      }).toList();

      return Quiz.fromJson({
        'id': qDoc.id,
        'title': qData['title'] ?? '',
        'subtitle': qData['subtitle'] ?? qData['description'] ?? '',
        'questions': questionsJson,
      });
    }).toList());

    return quizzes;
  }
}
