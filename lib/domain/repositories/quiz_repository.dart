import 'package:code_quiz/domain/models/quiz.dart';

/// Contract for fetching quizzes, independent of the data source.
abstract class QuizRepository {
  Future<List<Quiz>> getAllQuizzes();
}
