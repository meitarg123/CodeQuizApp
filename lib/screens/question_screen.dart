import 'package:code_quiz/domain/models/question.dart';
import 'package:flutter/material.dart';


class QuestionScreen extends StatefulWidget {
  final Question question;
  final int index;
  const QuestionScreen({super.key, required this.question, required this.index});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int? selectedIndex; //the answer selected by the user
  bool showResult = false; // show green or red

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${widget.index + 1}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Text(
            widget.question.text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        
          for (int i = 0; i < widget.question.options.length; i++)
            ListTile(
              onTap: () {
                setState(() {
                  selectedIndex = i;
                  showResult = true;
                });
              },
              title: Container(
                color: !showResult
                    ? Colors.transparent
                    : (widget.question.isCorrect(i)
                      ? Colors.green
                      : (selectedIndex == i
                        ? Colors.red
                        : Colors.transparent)),
                child: Text(widget.question.options[i]),
              ),
            ),
        ],
      ),
    );
  }
}
