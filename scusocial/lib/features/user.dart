import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart' show immutable;

// This model represents a user in the application, including their unique ID, friends list, full name, bio, and year of study.
@immutable
class UserModel {
  final String uid;
  final List<String> friends;
  //final String email;
  final String fullName;
  final String? bio;
  final String? year;

  const UserModel({
    required this.uid,
    required this.friends,
    //required this.email,
    required this.fullName,
    required this.bio,
    required this.year,

  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirebaseFieldNames.uid: uid,
      FirebaseFieldNames.friends: friends,
      //FirebaseFieldNames.email: email,
      FirebaseFieldNames.fullName: fullName,
      FirebaseFieldNames.bio: bio,
      FirebaseFieldNames.year: year,

    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[FirebaseFieldNames.uid] as String,
      friends: List<String>.from(map[FirebaseFieldNames.friends] ?? []),
      //email: map[FirebaseFieldNames.email] as String,
      fullName: map[FirebaseFieldNames.fullName] as String,
      bio: map[FirebaseFieldNames.bio] as String?,
      year: map[FirebaseFieldNames.year] as String?,

    );
  }
}
