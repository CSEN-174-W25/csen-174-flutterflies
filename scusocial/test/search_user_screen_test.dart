import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Fake Firestore: Search Users by Full Name', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Inject fake Firestore into the service
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);

    // Sample user data
    final List<Map<String, dynamic>> testUsers = [
      {'uid': 'user1', 'fullName': 'Alice Johnson', 'friends': []},
      {
        'uid': 'user2',
        'fullName': 'Bob Smith',
        'friends': ['user1']
      },
      {
        'uid': 'user3',
        'fullName': 'Charlie Brown',
        'friends': ['user2']
      },
      {
        'uid': 'user4',
        'fullName': 'Alice Cooper',
        'friends': ['user1', 'user3']
      },
    ];

    // Add test users to Firestore
    for (var user in testUsers) {
      await fakeFirestore.collection('users').doc(user['uid']).set(user);
    }

    // Search for users with name "Alice"
    final searchResults = await testFirestoreService.searchUsers("Alice");

    // Assertions
    expect(searchResults.length,
        2); // Expect 2 users (Alice Johnson & Alice Cooper)
    expect(
        searchResults.any((user) => user['fullName'] == 'Alice Johnson'), true);
    expect(
        searchResults.any((user) => user['fullName'] == 'Alice Cooper'), true);

    // Search for "Bob" (should return 1 result)
    final searchResultsBob = await testFirestoreService.searchUsers("Bob");
    expect(searchResultsBob.length, 1);
    expect(searchResultsBob.first['fullName'], 'Bob Smith');

    // Search for a non-existent name
    final searchResultsNotFound =
        await testFirestoreService.searchUsers("Zachary");
    expect(searchResultsNotFound.isEmpty, true);
  });

  test('Fake Firestore: Search Users by Partial Name', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);
    await fakeFirestore
        .collection('users')
        .doc('user5')
        .set({'uid': 'user5', 'fullName': 'Alicia Keys', 'friends': []});
    final searchResults = await testFirestoreService.searchUsers("Alic");
    expect(
        searchResults.any((user) => user['fullName'] == 'Alicia Keys'), true);
  });

  test('Fake Firestore: Search Users by Single Letter', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);
    await fakeFirestore
        .collection('users')
        .doc('user8')
        .set({'uid': 'user8', 'fullName': 'Charlie Chaplin', 'friends': []});
    final searchResults = await testFirestoreService.searchUsers("C");
    expect(searchResults.any((user) => user['fullName'] == 'Charlie Chaplin'),
        true);
  });

  test('Fake Firestore: Search Users by Full Name Match', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);
    await fakeFirestore
        .collection('users')
        .doc('user9')
        .set({'uid': 'user9', 'fullName': 'Emma Watson', 'friends': []});
    final searchResults = await testFirestoreService.searchUsers("Emma Watson");
    expect(searchResults.length, 1);
    expect(searchResults.first['fullName'], 'Emma Watson');
  });
  test('Fake Firestore: Search Users with Common Last Name', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final FirestoreService testFirestoreService =
        FirestoreService(firestore: fakeFirestore);
    await fakeFirestore
        .collection('users')
        .doc('user7')
        .set({'uid': 'user10', 'fullName': 'John Smith', 'friends': []});
    final searchResults = await testFirestoreService.searchUsers("John Smith");
    print(searchResults);

    expect(searchResults.any((user) => user['fullName'] == 'John Smith'), true);
  });
}
