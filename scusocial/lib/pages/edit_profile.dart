import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../features/user.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _yearController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final userData = userDoc.data();
    if (userData != null) {
      final user = UserModel.fromMap(userData);
      _bioController.text = user.bio ?? '';
      _yearController.text = user.year ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

        // Update Firestore
        await userDoc.update({
          'bio': _bioController.text,
          'year': _yearController.text,
        });

        // Update display name in FirebaseAuth
        //await user.updateDisplayName(_yearController.text);

        // Update profile picture if a new one was selected
        if (_imageFile != null) {
          // Upload the image to Firebase Storage and get the download URL
          final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid);
          await storageRef.putFile(_imageFile!);
          final photoURL = await storageRef.getDownloadURL();

          // Update photo URL in FirebaseAuth
          await user.updatePhotoURL(photoURL);

          // Update photo URL in Firestore
          await userDoc.update({
            'photoURL': photoURL,
          });
        }

        // Manually refresh the UI
        setState(() {});

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null ? const Icon(Icons.camera_alt, size: 50) : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}