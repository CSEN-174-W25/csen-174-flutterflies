import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {
  test('Fake Firestore: Add and Retrieve Comments', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    const String eventId = "testEvent123";
    const String userName = "Test User";
    const String message = "This is a test comment.";

    // Add a comment
    await testFirestoreService.addComment(
      eventId: eventId,
      userName: userName,
      message: message,
    );

    // Retrieve comments from the fake Firestore
    final snapshot = await fakeFirestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .get();

    final comments = snapshot.docs;

    // Assertions
    expect(comments.length, 1);
    final commentData = comments.first.data();

    expect(commentData['userName'], userName);
    expect(commentData['message'], message);
    expect(commentData.containsKey('timestamp'), true);
  });
}
