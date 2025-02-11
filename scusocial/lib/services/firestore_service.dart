import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<void> createEvent(
    String name,
    String description,
    String location,
    DateTime date,
    String time,
    String creatorId,
  ) async {
    await _firestore.collection('events').add({
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': time,
      'creatorId': creatorId,
      'accepted': [],
    });
  }
    Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final senderRef = _firestore.collection('users').doc(senderId);
    final receiverRef = _firestore.collection('users').doc(receiverId);

    await _firestore.runTransaction((transaction) async {
      final senderSnapshot = await transaction.get(senderRef);
      final receiverSnapshot = await transaction.get(receiverRef);

      if (!senderSnapshot.exists || !receiverSnapshot.exists) {
        throw Exception('User not found');
      }

      transaction.update(senderRef, {
        'sentRequests': FieldValue.arrayUnion([receiverId]),
      });

      transaction.update(receiverRef, {
        'receivedRequests': FieldValue.arrayUnion([senderId]),
      });
    });
  }

  /// Searches for users in Firestore whose `fullName` starts with `query`
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error during search: $e");
      return [];
    }
  }
}
