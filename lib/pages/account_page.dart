// lib/pages/account_page.dart

import 'package:flutter/material.dart';
import '../main.dart'; // Ensure this is correctly imported from your project

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = supabase.auth.currentUser;
    if (user != null) {
      // Load user data from Supabase
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single()
          .execute();

      if (response.data != null) {
        _usernameController.text = response.data['username'] ?? '';
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }
}
