import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserModel {
  final String uid;
  final List<String> friends;

  const UserModel({
    required this.uid,
    required this.friends,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirebaseFieldNames.uid: uid,
      FirebaseFieldNames.friends: friends,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[FirebaseFieldNames.uid] as String,
      friends: List<String>.from(map[FirebaseFieldNames.friends] ?? []),
    );
  }
}
