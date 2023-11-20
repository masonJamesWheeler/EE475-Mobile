import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_provider;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final supabaseClient = Provider.of<supabase_provider.SupabaseClient>(context, listen: false);

    // Use signIn for email and password authentication
    final result = await supabaseClient.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result.user != null) {
      // User successfully signed in
      Navigator.of(context).pushReplacementNamed('/account');
    } else {
      // Error occurred
      final snackBar = SnackBar(content: Text(result.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Sign In'),
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
          obscureText: true, // Hides the password
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Sign In'),
        ),
      ],
    ),
  );
}
}


