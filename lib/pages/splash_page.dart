import 'package:ee475_mobile/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';


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
    final database = Provider.of<DatabaseService>(context, listen: false);
    final session = database.supabase.auth.currentSession;
    setState(() {
      _isLoggedIn = session != null;
      _isChecking = false;
    });
  }

Future<bool> _onWillPop() async {
  return (await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Exit App'),
      content: Text('Do you really want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () => exit(0), // Using dart:io's exit() to close the app
          child: Text('Yes'),
        ),
      ],
    ),
  )) ?? false;
}

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: _onWillPop, // Intercepting the back button press
    child: Scaffold(
      body: _buildBody(), // Extracting body construction to a method for readability
    ),
  );
}

Widget _buildBody() {
  if (_isChecking) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_isLoggedIn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/account');
    });
    return const SizedBox(); // Temporary widget for the transition
  }

  return Stack(
    children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bck.png"), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Adjust the size of the column
          children: <Widget>[
            SizedBox(height: 10), // Increase or decrease the height as needed
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 85, 77, 172), // Button background color
                onPrimary: Colors.white, // Button text color
              ),
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 85, 77, 172), // Another contrasting color
                onPrimary: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Sign In'),
            ),
            ],
          ),
        ),
      ],
    );
  }
}
