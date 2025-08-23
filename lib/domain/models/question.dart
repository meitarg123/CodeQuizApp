class Question {
  final String text;
  final List<String> options;
  final int correctIndex; // index
  String? explanation;
  bool completed;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.completed = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
  return Question(
    text: json['text'] as String,
    options: (json['options'] as List).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String?,
    completed: (json['completed'] as bool?) ?? false,
  );
}

  bool isCorrect(int answer) {
    return answer == correctIndex;
  }

  bool isCompleted() {
    return completed;
  }

}
