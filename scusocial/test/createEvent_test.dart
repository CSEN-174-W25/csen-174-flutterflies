import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Fake Firestore: Add and Retrieve Events', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  // create 5 more similar tests
  test('Fake Firestore: Add and Retrieve Events 2', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  test('Fake Firestore: Add and Retrieve Events 3', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  test('Fake Firestore: Add and Retrieve Events 4', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  test('Fake Firestore: Add and Retrieve Events 5', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  test('Fake Firestore: Add and Retrieve Events 6', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
  test('Fake Firestore: Add and Retrieve Events 7', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testfirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Define test event details
    const String name = "Test Event";
    const String description = "This is a test event description.";
    const String location = "Test Location";
    final DateTime date = DateTime(2025, 2, 15); // Future date
    const String time = "3:00 PM";
    const String creatorId = "testUser123";

    // Add a test event
    await testfirestoreService.createEvent(
        name, description, location, date, time, creatorId);

    // Fetch events from the fake Firestore
    final snapshot = await fakeFirestore.collection('events').get();
    final events = snapshot.docs;

    // Assertions
    expect(events.length, 1); // Ensure one event was added
    final eventData = events.first.data();

    expect(eventData['name'], name);
    expect(eventData['description'], description);
    expect(eventData['location'], location);
    expect((eventData['date'] as Timestamp).toDate(), date);
    expect(eventData['time'], time);
    expect(eventData['creatorId'], creatorId);
  });
}
