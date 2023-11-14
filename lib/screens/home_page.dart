import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final SupabaseClient _supabaseClient = SupabaseClient('https://zisysdvhxncmwqwsiuyo.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inppc3lzZHZoeG5jbXdxd3NpdXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU5NTQ3NDEsImV4cCI6MjAxMTUzMDc0MX0.OSpXd1SR1PYx-nt2LsFcFYQpRovCZCFjJF1oJlMWbAY');

  Future<void> _addUserToDatabase(User? user) async {
    if (user != null) {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('uid', user.id)
          .execute();

      if (response.data == null || response.data.isEmpty) {
        // If user doesn't exist, add them to the database
        await _supabaseClient.from('users').insert({
          'uid': user.id,
          'email': user.email,
          // Add additional fields as necessary
        }).execute();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bck.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Adjust this value to position the content higher
              Text(
                'Welcome to Dog Collar App',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                child: Text('Create Account with Email'),
              ),
              Spacer(flex: 3), // This will push content up
            ],
          ),
        ),
      ),
    );
  }
}
