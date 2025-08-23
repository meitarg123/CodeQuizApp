import 'package:code_quiz/screens/question_screen.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import 'package:flutter/material.dart';


class QuizScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
      ),
      body: ListView.builder(
        itemCount: quiz.questions.length,
        itemBuilder: (context, index) {
          final question = quiz.questions[index];
          return ListTile(
              leading: CircleAvatar(radius: 14, child: Text('${index + 1}')),
              title: Text('Question ${index +1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // שלא יתפוס את כל הרוחב
                children: [
                  Icon(
                    question.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: question.completed ? Colors.green : null,
                  ),
                  const SizedBox(width: 6), // רווח קטן בין האייקון לטקסט
                  Text(
                    question.completed ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: question.completed ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to question details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionScreen(question: question, index: index),
                  ),
                );
                
              },
          );
        },
      ),
    );
  }
}