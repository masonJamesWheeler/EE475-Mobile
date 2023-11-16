import 'package:flutter/material.dart';
import '../main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _userName = ''; // Variable to store the user's name
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Fetch user data from your database
      final response = await supabase.from('users')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
      String fullName = response['name'];
      List<String> nameParts = fullName.split(' ');
      String firstName = nameParts.first; // Extracts the first name

      setState(() => _userName = firstName);
    } else {
      setState(() => _userName = 'No name');
    }

    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add_a_dog page
          Navigator.of(context).pushNamed('/add-a-dog');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add a Dog',
      ),
    );
  }
}
