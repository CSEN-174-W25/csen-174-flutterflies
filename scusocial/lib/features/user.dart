import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserModel {
  final String fullName;
  // final DateTime birthDay;
  // final String gender;
  // final String email;
  // final String password;
  // final String profilePicUrl;
  final String uid;
  final List<String> friends;
  final List<String> sentRequests;
  final List<String> receivedRequests;

  const UserModel({
    required this.fullName,
    // required this.birthDay,
    // required this.gender,
    // required this.email,
    // required this.password,
    // required this.profilePicUrl,
    required this.uid,
    required this.friends,
    required this.sentRequests,
    required this.receivedRequests,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirebaseFieldNames.fullName: fullName,
      // FirebaseFieldNames.birthDay: birthDay.millisecondsSinceEpoch,
      // FirebaseFieldNames.gender: gender,
      // FirebaseFieldNames.email: email,
      // FirebaseFieldNames.password: password,
      // FirebaseFieldNames.profilePicUrl: profilePicUrl,
      FirebaseFieldNames.uid: uid,
      FirebaseFieldNames.friends: friends,
      FirebaseFieldNames.sentRequests: sentRequests,
      FirebaseFieldNames.receivedRequests: receivedRequests,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    print('[DEBUG] Mapping Firestore data: $map');

    String? name = map[FirebaseFieldNames.fullName] as String?;
    print('[DEBUG] Extracted fullName: $name');

    return UserModel(
      fullName: name ?? 'Unknown User',
      uid: map[FirebaseFieldNames.uid] as String? ?? '',
      friends:
          List<String>.from((map[FirebaseFieldNames.friends] ?? <String>[])),
      sentRequests: List<String>.from(
          (map[FirebaseFieldNames.sentRequests] ?? <String>[])),
      receivedRequests: List<String>.from(
          (map[FirebaseFieldNames.receivedRequests] ?? <String>[])),
    );
  }
}
