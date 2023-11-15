// lib/pages/splash_page.dart

import 'package:flutter/material.dart';
import '../main.dart'; // Ensure this is correctly imported from your project

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isLoggedIn = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    final session = supabase.auth.currentSession;
    setState(() {
      _isLoggedIn = session != null;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/account');
      });
      return const Scaffold(); // Temporary scaffold for the transition
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

