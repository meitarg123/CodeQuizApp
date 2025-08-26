import '../models/user_progress.dart';

abstract class UserProgressRepository {
  Future<UserProgress> getProgress(String uid, String quizId); 
  Stream<UserProgress> watchProgress(String uid, String quizId); 

  Future<void> setQuestionCompleted(
    String uid, String quizId, String questionKey, bool completed);

  Future<void> setLastIndex(String uid, String quizId, int lastIndex);
}
