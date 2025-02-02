import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:scusocial/features/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  Fetches data for any specific user by id once when needed
*/ 

final getUserInfoByIdProvider =
    FutureProvider.autoDispose.family<UserModel, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection(FirebaseCollectionNames.users)
      .doc(userId)
      .get()
      .then((userData) {
    return UserModel.fromMap(userData.data()!);
  });
});