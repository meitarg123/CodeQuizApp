import 'package:flutter/material.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:code_quiz/screens/quiz_screen.dart';

import 'package:code_quiz/domain/repositories/quiz_repository.dart';

import '../data/firestore_quiz_repository.dart' as data;

// One concrete repository instance for the app lifetime.
final QuizRepository _repo = data.FirestoreQuizRepository();


// Load once (no repeated loads on rebuilds)
final Future<List<Quiz>> quizzes = _repo.getAllQuizzes();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.lightBlue,
      ),
      body: FutureBuilder<List<Quiz>>(
        future: quizzes,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          final quizzes = snapshot.data!; // List of quizzes from the file

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                child: ListTile(
                  title: Text(quiz.title),
                  subtitle: Text(quiz.subtitle ?? ''),
                  trailing: Text(
                    '${quiz.completedCount}/${quiz.totalQuestions}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)),
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
