import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database_service.dart';
import 'dog_details_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _userName = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _dogs = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final database = Provider.of<DatabaseService>(context, listen: false);
      final user = database.supabase.auth.currentUser;
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final response = await database.supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        String fullName = response['name'];
        List<String> nameParts = fullName.split(' ');
        String firstName = nameParts.first;

        setState(() => _userName = firstName);

        var dogs = await database.fetchDogs();
        setState(() => _dogs = dogs);
      } else {
        setState(() => _userName = 'No name');
      }
    } catch (e) {
      print(' user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final database = Provider.of<DatabaseService>(context, listen: false);
    database.authState.logout();
    database.supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<bool> _onWillPop() async {
    await _signOut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/add-a-dog');
          },
          child: const Icon(Icons.add),
          tooltip: 'Add a Dog',
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _isLoading
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
                Expanded(
                  child: ListView.builder(
                    itemCount: _dogs.length,
                    itemBuilder: (context, index) {
                      var dog = _dogs[index];
                      return Card(
                        child: ListTile(
                          title: Text(dog['name']),
                          subtitle: Text(
                              'Breed: ${dog['breed']}, Weight: ${dog['weight']} lbs'),
                          trailing: Icon(Icons.pets),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DogDetailsPage(dogData: dog),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
  }
}
