import 'package:flutter/material.dart';
import 'package:code_quiz/screens/home_screen.dart';


class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CODE QUIZ'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen(),
                  ),
                );
              },
              child: const Text('Start'),
            ),

            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
