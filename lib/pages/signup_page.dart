// lib/pages/signup_page.dart

import 'package:flutter/material.dart';
import '../main.dart'; // Ensure this is correctly imported from your project

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateUserProfile(String userId, String email) async {
    final response = await supabase.from('users').upsert({
      'id': userId,
      'email': email,
    }).execute();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final result = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString())),
      );
    } else {
      // Check if email and userid are not null
      if (result.user!.email != null && result.user!.id != null) {
        await _updateUserProfile(result.user!.id, result.user!.email!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Registration successful! Please check your email to confirm your account.')),
      );
      Navigator.of(context).pop(); // Go back to the previous screen
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
