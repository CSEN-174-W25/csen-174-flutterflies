import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import '../../core/constants/firebase_constants.dart';

@immutable
class FriendRepository {
  // Initialize FirebaseAuth and FirebaseFirestore instances
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FriendRepository({required this.auth, required this.firestore});

  // Get the current user's UID
  String get _myUid => auth.currentUser!.uid;

  // Initialize user document
  Future<void> initializeUserDocument(String uid) async {
    final docRef = firestore.collection(FirebaseCollectionNames.users).doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        FirebaseFieldNames.uid: uid,
        FirebaseFieldNames.friends: [],
        FirebaseFieldNames.buttonPressCount: 0, // Default value
      });
    }
  }

  // Send friend request (stores request in 'friendRequests' collection)
  Future<String?> sendFriendRequest({required String userId}) async {
    try {
      final requestRef = firestore
          .collection(FirebaseCollectionNames.friendRequests)
          .doc('${_myUid}_$userId');

      await requestRef.set({
        FirebaseFieldNames.from: _myUid,
        FirebaseFieldNames.to: userId,
        FirebaseFieldNames.status: "pending"
      });

      return null;
    } catch (e) {
      print("Error sending friend request: $e");
      return e.toString();
    }
  }

  // Method to accept a friend request 
  Future<String?> acceptFriendRequest({required String userId}) async {
    try {
      final requestRef = firestore
          .collection(FirebaseCollectionNames.friendRequests)
          .doc('${userId}_$_myUid');

      print("Accepting friend request from $userId");

      // Update request status to accepted
      await requestRef.update({FirebaseFieldNames.status: "accepted"});

      // Add each user to the other's friends list
      print("Adding $userId to $_myUid friends list");
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(_myUid)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([userId])
      });

      print("Adding $_myUid to $userId's friends list");
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(userId)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([_myUid])
      });

      // **Delete the request after both users have been added as friends**
      print("Friend request accepted. Deleting request...");
      await requestRef.delete();

      print("Friend request deleted.");
      return null;
    } catch (e) {
      print("Error accepting friend request: $e");
      return e.toString();
    }
  }

  // Decline (or cancel) friend request
  Future<String?> declineFriendRequest({required String userId}) async {
    try {
      final requestRef = firestore
          .collection(FirebaseCollectionNames.friendRequests)
          .doc('${userId}_$_myUid');

      await requestRef.delete();
      return null;
    } catch (e) {
      print("Error declining friend request: $e");
      return e.toString();
    }
  }

  // Remove friend
  Future<String?> removeFriend({required String userId}) async {
    try {
      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(_myUid)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([userId])
      });

      await firestore
          .collection(FirebaseCollectionNames.users)
          .doc(userId)
          .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([_myUid])
      });

      return null;
    } catch (e) {
      print("Error removing friend: $e");
      return e.toString();
    }
  }

  // get list of friends
  Stream<List<String>> getFriends({required String userId}) {
    return firestore
        .collection(FirebaseCollectionNames.users)
        .doc(_myUid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return List<String>.from(data[FirebaseFieldNames.friends]);
    });
  }
}
