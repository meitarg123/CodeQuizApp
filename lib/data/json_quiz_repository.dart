import 'package:code_quiz/domain/repositories/quiz_repository.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:code_quiz/data/load_quizzes.dart';

/// Repository implementation backed by a local JSON asset.
class JsonQuizRepository implements QuizRepository {
  @override
  Future<List<Quiz>> getAllQuizzes() {
    return loadQuizzesFromAssets();
  }
}
