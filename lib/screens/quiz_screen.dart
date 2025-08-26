import 'package:code_quiz/screens/question_screen.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';
import '../data/firestore_user_progress_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:code_quiz/domain/models/user_progress.dart';

final _progressRepo = FirestoreUserProgressRepository();
String _quizKey(String title) => title.replaceAll('/', '_');
String questionKeyFromIndex(int i) => 'q_${i.toString().padLeft(3, '0')}';

String? get _currentUidOrNull => FirebaseAuth.instance.currentUser?.uid;

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;

    return Scaffold(
      appBar: AppBar(title: Text(quiz.title)),
      body: Builder(
        builder: (context) {
          final uid = _currentUidOrNull;
          if (uid == null) {
            // אם אין משתמש מחובר
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('לא מחובר/ת', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/start'),
                    child: const Text('להתחברות'),
                  ),
                ],
              ),
            );
          }

          final quizKey = _quizKey(quiz.title);

          return StreamBuilder<UserProgress>(
            stream: _progressRepo.watchProgress(uid, quizKey),
            initialData: UserProgress.empty(quizKey),
            builder: (context, snap) {
              final completedIds = snap.data?.completedQuestionIds ?? <String>{};

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: quiz.questions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final qKey = questionKeyFromIndex(index);
                  final isDone = completedIds.contains(qKey);
                  final question = quiz.questions[index];

                  return ListTile(
                    key: ValueKey(qKey),
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Question ${index + 1}'),
                    subtitle: Text(question.text),
                    trailing: Icon(
                      isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isDone ? Colors.green : null,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionScreen(
                            quiz: quiz,
                            startIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
