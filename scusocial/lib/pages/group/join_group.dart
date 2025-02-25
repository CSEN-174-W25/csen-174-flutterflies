import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGroupPage extends StatelessWidget {
  final String groupId;

  JoinGroupPage({required this.groupId});

  Future<void> _joinGroup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join Group')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _joinGroup(context),
          child: Text('Join Group'),
        ),
      ),
    );
  }
}