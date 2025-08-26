class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex; 
  final String? explanation;
  bool completed; 

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.completed = false, 
  });

  /// Creates a Question from a JSON object.
  factory Question.fromJson(Map<String, dynamic> json) {
  return Question(
    id: json['id'] as String? ?? '',
    text: json['text'] as String,
    options: (json['options'] as List).cast<String>(),
    correctIndex: (json['correctIndex']) as int,
    explanation: json['explanation'] as String?,
    // completed: (json['completed'] as bool?) ??  - false is the default. progress is the truth result
  );
}

  bool isCorrect(int answer) {
    return answer == correctIndex;
  }

}
