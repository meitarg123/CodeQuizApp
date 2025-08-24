//if not signed in, show button "login with Google", else show start screen
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';

class AuthGate extends StatefulWidget {
  final Widget child; //show after login
  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _users = UserRepository();
  bool _busy = false; // Indicates if a login request is in progress

  Future<void> _login() async {
    try {
      setState(() => _busy = true);
      final cred = await _auth.signInWithGoogle();
      await _users.upsertUser(cred.user!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error in login: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: _auth.authStateChanges,
    builder: (context, snap) {
      final user = snap.data;
      if (user == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Code Quiz',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome! Please sign in to start playing',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: _busy ? null : _login,
                  icon: const Icon(Icons.login),
                  label: const Text('Login with Google'),
                ),
              ],
            ),
          ),
        );
      }
      return widget.child; // Logged in → continue to the app
    },
  );
}

}
