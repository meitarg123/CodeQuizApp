import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:code_quiz/domain/models/quiz.dart';

/// Loads quizzes from a local JSON file bundled as an asset.

Future<List<Quiz>> loadQuizzesFromAssets() async {
  // 1) Read the file contents as a String from the asset bundle
  final raw = await rootBundle.loadString('assets/data/quizzes.json'); //read-only access

  // 2) Decode the JSON into a dynamic List (array of quizzes)
  final list = jsonDecode(raw) as List<dynamic>;

  // 3) Convert each JSON object (Map) into a typed `Quiz`
  return list
      .map((m) => Quiz.fromJson(m as Map<String, dynamic>))
      .toList();
}
