class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex; 
  String? explanation;
  bool completed; // true = answered correctly, false = pending

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.completed = false, 
  });

  factory Question.fromJson(Map<String, dynamic> json) {
  return Question(
    id: json['id'] as String? ?? '',
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
  
}
