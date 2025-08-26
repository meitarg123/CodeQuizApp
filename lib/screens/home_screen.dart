import 'package:flutter/material.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:code_quiz/screens/quiz_screen.dart';

import 'package:code_quiz/domain/models/user_progress.dart';
import 'package:code_quiz/domain/repositories/user_progress_repository.dart';
import '../data/firestore_user_progress_repository.dart';

import 'package:code_quiz/domain/repositories/quiz_repository.dart';
import '../data/firestore_quiz_repository.dart' as data;

import 'package:firebase_auth/firebase_auth.dart';

// ----- Singletons -----
final QuizRepository _repo = data.FirestoreQuizRepository();
final UserProgressRepository _progressRepo = FirestoreUserProgressRepository();

String _quizKey(String title) => title.replaceAll('/', '_');

String get currentUid {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) {
    throw StateError('No user is signed in');
  }
  return u.uid;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Quiz>> _quizzes;

  @override
  void initState() {
    super.initState();
    _quizzes = _repo.getAllQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.lightBlue,
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          final quizzes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];

              return Card(
                child: ListTile(
                  title: Text(quiz.title),
                  subtitle: Text(quiz.subtitle ?? ''),
                  trailing: StreamBuilder<UserProgress>(
                    stream: _progressRepo.watchProgress(
                      currentUid,                
                      _quizKey(quiz.title),
                    ),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return const Text(
                          'err',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        );
                      }

                      final progress =
                          snap.data ?? UserProgress.empty(_quizKey(quiz.title));

                      // Prefer totalQuestions; fallback to questions.length
                      int total;
                      try {
                        total = quiz.totalQuestions;
                        if (total == 0) total = quiz.questions.length;
                      } catch (_) {
                        total = quiz.questions.length;
                      }

                      return Text(
                        '${progress.completedCount}/$total',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(quiz: quiz),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
