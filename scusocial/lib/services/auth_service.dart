import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/calendar_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "922633706004-qmprgr02q0h82p38p31v7ofm3uigj446.apps.googleusercontent.com");

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CalendarService _calendarService = CalendarService();

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        await _initializeUser(user); // Ensure the user exists first
        await _handleUserCalendar(user); // Then handle the calendar
      }

      return user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _initializeUser(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': user.displayName ?? '',
        'uid': user.uid,
        'friends': [], // Initialize as empty array
        'calendarId': null, // Placeholder for calendar fields
        'calendarLink': null,
        'bio': 'I am new to Herd!',
      }, SetOptions(merge: true));
    }
  }

  Future<void> _handleUserCalendar(User user) async {
    final calendarLink =
        await _calendarService.ensureUserHasCalendar(user.uid, user.email!);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
