import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Controller for name input
  bool _isLoading = false;

  Future<void> _updateUserProfile(String userId, String email, String name) async {
    final database = Provider.of<DatabaseService>(context, listen: false);
    await database.supabase.from('users').upsert({
      'id': userId,
      'email': email,
      'name': name,
    }).execute();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final database = Provider.of<DatabaseService>(context, listen: false);

    final result = await database.supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result.user != null && result.user!.email != null) {
      await _updateUserProfile(result.user!.id, result.user!.email!, _nameController.text.trim());
      database.authState.login(); // Update AuthState on successful signup
      Navigator.of(context).pushReplacementNamed('/account');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registration failed, please try again.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Sign Up'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // This line will navigate back to the previous screen in the navigation stack
          Navigator.of(context).pop();
        },
      ),
    ),
      
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
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
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
