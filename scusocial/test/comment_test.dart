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
  test('Fake Firestore: Add and Retrieve Comments with empty message',
      () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    const String eventId = "testEvent123";
    const String userName = "Test User";
    const String message = "";

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
    expect(comments.length, 0);
  });
  test('Fake Firestore: Add and Retrieve Comments with special characters',
      () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    const String eventId = "testEvent123";
    const String userName = "Test User";
    const String message = "!@#\$%^&*()_+";

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
  test('Fake Firestore: Add and Retrieve Comments with long message', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    const String eventId = "testEvent123";
    const String userName = "Test User";
    final String message = List.generate(1000, (index) => 'a').join();

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
  test('Fake Firestore: Add and Retrieve Comments with timestamp', () async {
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
  test('Fake Firestore: Add and Retrieve Comments with empty userName',
      () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    const String eventId = "testEvent123";
    const String userName = "";
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

    expect(commentData['userName'], 'Anonymous');
    expect(commentData['message'], message);
    expect(commentData.containsKey('timestamp'), true);
  });
}
