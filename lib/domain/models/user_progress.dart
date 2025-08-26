// Represents the user's progress in a quiz.
class UserProgress {
  final String quizId;
  final Set<String> completedQuestionIds; // IDs of completed questions
  final int lastIndex; // Index of the last answered question

  const UserProgress({
    required this.quizId,
    required this.completedQuestionIds,
    this.lastIndex = 0,
  });

  int get completedCount => completedQuestionIds.length;

  /// Toggles the completion status of a question.
  UserProgress toggle(String qid, bool completed) {
    final next = Set<String>.from(completedQuestionIds);
    completed ? next.add(qid) : next.remove(qid);
    return UserProgress(
      quizId: quizId,
      completedQuestionIds: next,
      lastIndex: lastIndex,
    );
  }

  factory UserProgress.empty(String quizId) =>
      UserProgress(quizId: quizId, completedQuestionIds: const {}, lastIndex: 0);
}
