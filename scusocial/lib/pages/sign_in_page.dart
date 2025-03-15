import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'event_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isSigningIn = false;

  // method handles Google sign-in process
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    final user = await _authService.signInWithGoogle();

    if (user != null) {
      setState(() {
        _user = user;
      });
    }

    setState(() {
      _isSigningIn = false;
    });
  }

  // method handles sign-out process
  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Set AppBar height
        child: AppBar(
          centerTitle: true,
          flexibleSpace: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers the logo properly
            children: [
              SizedBox(height: 0), // Adjust spacing as needed
              Image.asset(
                'assets/herdlogo.png',
                height: 100, // Adjust size separately
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: _user == null
            ? _isSigningIn
                ? CircularProgressIndicator() // Show spinner while signing in
                : ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: Text('Sign in with Google'),
                  )
            : EventPage(
                user: _user!,
                signOut: _signOut,
                eventIsTesting: false,
              ),
      ),
    );
  }
}
