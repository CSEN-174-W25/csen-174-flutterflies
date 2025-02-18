import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import '../../core/constants/firebase_constants.dart';

@immutable
class FriendRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FriendRepository({required this.auth, required this.firestore});

  String get _myUid => auth.currentUser!.uid;

  // Initialize user document
  Future<void> initializeUserDocument(String uid) async {
    final docRef = firestore.collection(FirebaseCollectionNames.users).doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        FirebaseFieldNames.uid: uid,
        FirebaseFieldNames.friends: [],
        FirebaseFieldNames.receivedRequests: [],
        FirebaseFieldNames.sentRequests: [],
        FirebaseFieldNames.buttonPressCount: 0, // Default value
      });
    }
  }

  // Send friend request
  Future<String?> sendFriendRequest({required String userId}) async {
    try {
      final receiverDocRef =
          firestore.collection(FirebaseCollectionNames.users).doc(userId);
      final senderDocRef =
          firestore.collection(FirebaseCollectionNames.users).doc(_myUid);

      final receiverSnapshot = await receiverDocRef.get();
      if (!receiverSnapshot.exists) {
        await receiverDocRef.set({
          FirebaseFieldNames.receivedRequests: [_myUid],
        });
      } else {
        await receiverDocRef.update({
          FirebaseFieldNames.receivedRequests: FieldValue.arrayUnion([_myUid]),
        });
      }

      final senderSnapshot = await senderDocRef.get();
      if (!senderSnapshot.exists) {
        await senderDocRef.set({
          FirebaseFieldNames.uid: _myUid,
          FirebaseFieldNames.friends: [],
          FirebaseFieldNames.receivedRequests: [],
          FirebaseFieldNames.sentRequests: [],
          FirebaseFieldNames.buttonPressCount: 0
        });
      }

      await senderDocRef.update({
        FirebaseFieldNames.sentRequests: FieldValue.arrayUnion([userId]),
      });

      return null;
    } catch (e) {
      print("Error sending friend request: $e");
      return e.toString();
    }
  }

  // Accept friend request
  Future<String?> acceptFriendRequest({required String userId}) async {
    try {
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(userId)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([_myUid]),
      });

      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(_myUid)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([userId]),
      });
      print("Friend request accepted");

      await removeFriendRequest(userId: userId);
      return null;
    } catch (e) {
      print("Error accepting friend request: $e");
      return e.toString();
    }
  }

  // Remove friend request
  Future<String?> removeFriendRequest({required String userId}) async {
    print("Removing friend request from $userId");
    try {
      print('Removing received request containing $userId from $_myUid');
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(_myUid)
          .update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayRemove([userId]),
      });
      // cant remove from another users sent requests because we dont have access to it
      // await firestore
      //     .collection(FirebaseCollectionNames.users)
      //     .doc(userId)
      //     .update({
      //   FirebaseFieldNames.sentRequests: FieldValue.arrayRemove([_myUid]),
      // });
      print("Friend request removed");

      return null;
    } catch (e) {
      print("Error removing friend request: $e");
      return e.toString();
    }
  }

  // Remove friend
  Future<String?> removeFriend({required String userId}) async {
    try {
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(userId)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([_myUid]),
      });

      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(_myUid)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([userId]),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
