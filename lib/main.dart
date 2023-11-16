// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/account_page.dart';
import 'pages/add_a_dog.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://zisysdvhxncmwqwsiuyo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inppc3lzZHZoeG5jbXdxd3NpdXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU5NTQ3NDEsImV4cCI6MjAxMTUzMDc0MX0.OSpXd1SR1PYx-nt2LsFcFYQpRovCZCFjJF1oJlMWbAY',
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(), // Add this line
        '/account': (context) => const AccountPage(),
        '/add-a-dog': (context) => const AddADogPage(), // Add this line

      },
    );
  }
}
