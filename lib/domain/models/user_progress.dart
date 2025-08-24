class UserProgress {
  final String quizId;
  final Set<String> completedQuestionIds;

  const UserProgress({required this.quizId, required this.completedQuestionIds});

  int get completedCount => completedQuestionIds.length;

  UserProgress toggle(String qid, bool completed) {
    final next = Set<String>.from(completedQuestionIds);
    completed ? next.add(qid) : next.remove(qid);
    return UserProgress(quizId: quizId, completedQuestionIds: next);
  }

  factory UserProgress.empty(String quizId) =>
      UserProgress(quizId: quizId, completedQuestionIds: const {});
}
