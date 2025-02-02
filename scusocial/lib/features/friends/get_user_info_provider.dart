import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:scusocial/features/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  Fetches data for the logged in user once when needed
*/ 
final getUserInfoProvider = FutureProvider.autoDispose<UserModel>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseCollectionNames.users)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((userData) {
    return UserModel.fromMap(userData.data()!);
  });
});