import '../models/user_progress.dart';

abstract class UserProgressRepository {
  Future<UserProgress> getProgress(String uid, String quizId);
  Stream<UserProgress> watchProgress(String uid, String quizId); // לנוחות ב־UI
  Future<void> setQuestionCompleted(
    String uid, String quizId, String questionId, bool completed);
}
