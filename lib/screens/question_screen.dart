import 'dart:async';
import 'package:flutter/material.dart';
import 'package:code_quiz/domain/models/quiz.dart';
import '../data/firestore_user_progress_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _progressRepo = FirestoreUserProgressRepository();
String _quizKey(String title) => title.replaceAll('/', '_');
String questionKeyFromIndex(int i) => 'q_${i.toString().padLeft(3, '0')}';

String get currentUid {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) throw StateError('No user is signed in');
  return u.uid;
}

class QuestionScreen extends StatefulWidget {
  final Quiz quiz;
  final int startIndex;

  const QuestionScreen({super.key, required this.quiz, this.startIndex = 0});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late int _index;
  int? _selectedOption;
  bool _alreadyCompletedThisQuestion = false; // מונע כתיבה כפולה
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    // מכבדים אך ורק את מה שהגיע מהמסך הקודם; אין Resume אוטומטי
    final lastValid = widget.quiz.questions.isEmpty
        ? 0
        : widget.startIndex.clamp(0, widget.quiz.questions.length - 1);
    _index = lastValid;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _markCompletedOnce() async {
    if (_alreadyCompletedThisQuestion) return; // לא מסמנים שוב
    _alreadyCompletedThisQuestion = true;
    final qKey = questionKeyFromIndex(_index);
    await _progressRepo.setQuestionCompleted(
      currentUid,
      _quizKey(widget.quiz.title),
      qKey,
      true,
    );
  }

  void _onOptionTap(int optionIndex) {
    final question = widget.quiz.questions[_index];
    setState(() => _selectedOption = optionIndex);

    // סימון אוטומטי כהושלם רק אם נכון ובפעם הראשונה
    if (optionIndex == question.correctIndex) {
      _markCompletedOnce();
    }
  }

  void _setIndexAndPersist(int next) {
    setState(() {
      _index = next;
      _selectedOption = null;
      _alreadyCompletedThisQuestion = false; // לשאלה הבאה מותר שוב
    });

    // נשמור lastIndex (זה לא יגרום לחזרה אוטומטית — אנחנו לא משתמשים בזה ב-init)
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () {
      _progressRepo.setLastIndex(currentUid, _quizKey(widget.quiz.title), _index);
    });
  }

  void _goNext() {
    if (_index < widget.quiz.questions.length - 1) {
      _setIndexAndPersist(_index + 1);
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_index];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.quiz.title} • Q${_index + 1}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final option = question.options[i];
                  final isSelected = _selectedOption == i;
                  final isCorrect = i == question.correctIndex;

                  final borderColor = isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.shade300;

                  return InkWell(
                    onTap: () => _onOptionTap(i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _goNext,
              child: Text(
                (_index < widget.quiz.questions.length - 1) ? 'Next' : 'Finish',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
