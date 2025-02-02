import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:scusocial/features/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  Fetches data for any specific user by id once when needed
*/

final getUserInfoByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (!doc.exists) {
    print('[ERROR] No document found for UID: $uid');
    return null;
  }

  final data = doc.data();
  print('[DEBUG] Firestore returned data: $data');

  return data != null ? UserModel.fromMap(data) : null;
});
