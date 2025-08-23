import 'package:code_quiz/domain/models/question.dart';

class Quiz {
  final String title;
  String? subtitle;
  List<Question> questions = [];  // List of questions in the quiz
  int answeredQuestions;

  Quiz({
    required this.title,
    this.subtitle,
    required this.questions,
    this.answeredQuestions = 0,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      questions: (json['questions'] as List)
          .map((m) => Question.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalQuestions => questions.length;


  double get progress => totalQuestions == 0 ? 0 : answeredQuestions / totalQuestions;
  int get progressPercent => ((progress) * 100).round();

}
