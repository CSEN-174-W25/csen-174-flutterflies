import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

// CreateGroupPageState handles state for the CreateGroupPage widget.
class _CreateGroupPageState extends State<CreateGroupPage> {
  // Form key validates form inputs
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // _createGroup method creates a new group in Firestore and adds current user as a member and leader.
  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;
      final String userID = user!.uid;

      // Create a new group in Firestore 
      await FirebaseFirestore.instance.collection('groups').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'members': [userID],
        'leader': userID,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group created successfully')),
      );

      _nameController.clear();
      _descriptionController.clear();

      Navigator.pop(context);
    }
  }

  // build method that returns UI for CreateGroupPage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextFormField for group name input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              // TextFormField for description input
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Create Group Button
              ElevatedButton(
                onPressed: _createGroup,
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
