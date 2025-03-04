import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserModel {
  final String uid;
  final List<String> friends;
  //final String email;
  final String fullName;
  final String? bio;

  const UserModel({
    required this.uid,
    required this.friends,
    //required this.email,
    required this.fullName,
    required this.bio,

  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirebaseFieldNames.uid: uid,
      FirebaseFieldNames.friends: friends,
      //FirebaseFieldNames.email: email,
      FirebaseFieldNames.fullName: fullName,
      FirebaseFieldNames.bio: bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[FirebaseFieldNames.uid] as String,
      friends: List<String>.from(map[FirebaseFieldNames.friends] ?? []),
      //email: map[FirebaseFieldNames.email] as String,
      fullName: map[FirebaseFieldNames.fullName] as String,
      bio: map[FirebaseFieldNames.bio] as String?,

    );
  }
}
