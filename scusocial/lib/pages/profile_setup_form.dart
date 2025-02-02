import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileSetupForm extends StatefulWidget {
  final String uid;

  const ProfileSetupForm({super.key, required this.uid});

  @override
  _ProfileSetupFormState createState() => _ProfileSetupFormState();
}

class _ProfileSetupFormState extends State<ProfileSetupForm> {
  final TextEditingController _fullNameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveProfile() async {
    if (_fullNameController.text.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'fullName': _fullNameController.text.trim(),
        'uid': widget.uid,
        'friends': [], // ✅ Initialize as empty array
        'sentRequests': [], // ✅ Initialize as empty array
        'receivedRequests': [], // ✅ Initialize as empty array
      }, SetOptions(merge: true));

      print('[DEBUG] User profile saved successfully!');

      // ✅ Pop back to ProfileScreen
      Navigator.pop(context);
    } catch (e) {
      print('[ERROR] Failed to save profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your profile details to continue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
