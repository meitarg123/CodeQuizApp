import 'package:code_quiz/domain/models/question.dart';

class Quiz {
  final String title;
  final String? subtitle;
  final List<Question> questions;

  Quiz({
    required this.title,
    this.subtitle,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
      final raw = (json['questions'] as List? ?? []);

      final normalizedQuestionsJson = raw.asMap().entries.map((entry) {
        final i = entry.key;
        final m = Map<String, dynamic>.from(entry.value as Map);

        final hasId = (m['id'] is String) && (m['id'] as String).trim().isNotEmpty;
        m['id'] = hasId ? (m['id'] as String) : 'q${i + 1}';

        m.remove('completed'); // completed is for UI only

        return m;
      }).toList();

      final qs = normalizedQuestionsJson
          .map((m) => Question.fromJson(m))
          .toList();

      return Quiz(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        questions: qs,
      );
  }

  int get totalQuestions => questions.length;

  //number of completed questions
  int get completedCount => questions.where((q) => q.completed).length;

  double get progress => totalQuestions == 0 ? 0 : completedCount / totalQuestions;

  int get progressPercent => (progress * 100).round();
}
