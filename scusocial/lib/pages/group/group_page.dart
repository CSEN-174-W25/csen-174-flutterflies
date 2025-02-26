import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<String> _groupName = [];
  List<String> _groupMembers = [];

  Future getGroupName() async {
    await FirebaseFirestore.instance
        .collection('groups')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              print(element.reference);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Page')),
      body: Center(
        child: Text('Group Page'),
      ),
    );
  }
}
