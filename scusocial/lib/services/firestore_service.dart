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

  Future<void> addComment({
    required String eventId,
    required String userName,
    required String message,
  }) async {
    if (message.isEmpty) return;

    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .add({
      'userName': userName.isNotEmpty ? userName : 'Anonymous',
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches comments for an event (useful for testing)
  Stream<QuerySnapshot> getComments(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }
}
