// lib/data/firestore_quiz_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_quiz/domain/repositories/quiz_repository.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:code_quiz/domain/models/question.dart';

class FirestoreQuizRepository implements QuizRepository {
  final FirebaseFirestore _db;

  FirestoreQuizRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<Quiz>> getAllQuizzes() async {
    // No orderBy -> no composite index needed
    final quizzesSnap = await _db
        .collection('quizzes')
        .where('isPublished', isEqualTo: true)
        .get();

    final quizzes = await Future.wait(quizzesSnap.docs.map((qDoc) async {
      final qData = qDoc.data();

      // Also no orderBy here (questions)
      final questionsSnap = await _db
          .collection('quizzes')
          .doc(qDoc.id)
          .collection('questions')
          .get();

      final questions = questionsSnap.docs.map((d) {
        final m = d.data();
        final options = (m['options'] as List).map((e) => e.toString()).toList();

        return Question(
          text: m['text'] as String? ?? '',
          options: options,
          correctIndex: (m['correctIndex'] as num).toInt(),
          explanation: m['explanation'] as String?,
          completed: (m['completed'] as bool?) ?? false,
        );
      }).toList();

      // Build Quiz using your existing fromJson
      return Quiz.fromJson({
        'id': qDoc.id,
        'title': qData['title'] ?? '',
        // prefer 'subtitle' if exists; fallback to 'description'
        'subtitle': qData['subtitle'] ?? qData['description'] ?? '',
        'questions': questions
            .map((qq) => {
                  'text': qq.text,
                  'options': qq.options,
                  'correctIndex': qq.correctIndex,
                  'explanation': qq.explanation,
                  'completed': qq.completed,
                })
            .toList(),
      });
    }).toList());

    return quizzes;
  }
}
