import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        _addUserToDatabase(userCredential.user);
        return userCredential.user;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> _addUserToDatabase(User? user) async {
    if (user != null) {
      final DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        // If user doesn't exist, add them to the database
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        });
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
                style: GoogleFonts.roboto( // Using a modern font
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
              ElevatedButton(
                onPressed: () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    print('Google Sign In Success: ${user.displayName}');
                  }
                },
                child: Text('Sign In with Google'),
              ),
              Spacer(flex: 3), // This will push content up
            ],
          ),
        ),
      ),
    );
  }
}