import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/constants/firebase_constants.dart';
import '/features/user.dart';

/*
  Fetches data for any user by Id (live updates)
*/ 

final getUserInfoAsStreamByIdProvider =
    StreamProvider.autoDispose.family<UserModel, String>((ref, String userId) {
  final controller = StreamController<UserModel>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionNames.users)
      .where(FirebaseFieldNames.uid, isEqualTo: userId)
      .limit(1)
      .snapshots()
      .listen((snapshot) {
    final userData = snapshot.docs.first;
    final user = UserModel.fromMap(userData.data());
    controller.sink.add(user);
  });

  ref.onDispose(() {
    controller.close();
    sub.cancel();
  });

  return controller.stream;
});