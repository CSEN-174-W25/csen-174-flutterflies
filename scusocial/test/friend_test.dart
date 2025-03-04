// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:scusocial/features/friends/friend-repo.dart';

// void main() {
//   late FakeFirebaseFirestore fakeFirestore;
//   late MockFirebaseAuth mockAuth;
//   late FriendRepository friendRepo;

//   setUp(() {
//     fakeFirestore = FakeFirebaseFirestore();
//     mockAuth = MockFirebaseAuth(
//         signedIn: true, mockUser: MockUser(uid: 'testUser123'));
//     friendRepo = FriendRepository(auth: mockAuth, firestore: fakeFirestore);
//   });

//   test('Initialize user document if it does not exist', () async {
//     final userId = 'newUser456';
//     await friendRepo.initializeUserDocument(userId);

//     final userDoc = await fakeFirestore.collection('users').doc(userId).get();
//     expect(userDoc.exists, true);
//     expect(userDoc.data(), {
//       'uid': userId,
//       'friends': [],
//       'receivedRequests': [],
//       'sentRequests': [],
//       'buttonPressCount': 0,
//     });
//   });

//   test('Send a friend request', () async {
//     final targetUserId = 'friend456';

//     await friendRepo.sendFriendRequest(userId: targetUserId);

//     final receiverDoc =
//         await fakeFirestore.collection('users').doc(targetUserId).get();
//     final senderDoc = await fakeFirestore
//         .collection('users')
//         .doc(mockAuth.currentUser!.uid)
//         .get();

//     expect(receiverDoc.data()?['receivedRequests'], contains('testUser123'));
//     expect(senderDoc.data()?['sentRequests'], contains(targetUserId));
//   });

//   test('Accept a friend request', () async {
//     final targetUserId = 'friend789';

//     // Simulate sending a request
//     await friendRepo.sendFriendRequest(userId: targetUserId);

//     // Accept friend request
//     await friendRepo.acceptFriendRequest(userId: targetUserId);

//     final targetUserDoc =
//         await fakeFirestore.collection('users').doc(targetUserId).get();
//     final currentUserDoc = await fakeFirestore
//         .collection('users')
//         .doc(mockAuth.currentUser!.uid)
//         .get();

//     expect(targetUserDoc.data()?['friends'], contains('testUser123'));
//     expect(currentUserDoc.data()?['friends'], contains(targetUserId));

//     // Request should be removed after accepting
//     expect(targetUserDoc.data()?['receivedRequests'],
//         isNot(contains('testUser123')));
//     expect(
//         currentUserDoc.data()?['sentRequests'], isNot(contains(targetUserId)));
//   });

//   test('Remove a friend request', () async {
//     final targetUserId = 'friend101';

//     // Simulate sending a request
//     await friendRepo.sendFriendRequest(userId: targetUserId);

//     // Remove friend request
//     await friendRepo.removeFriendRequest(userId: targetUserId);

//     final targetUserDoc =
//         await fakeFirestore.collection('users').doc(targetUserId).get();
//     final currentUserDoc = await fakeFirestore
//         .collection('users')
//         .doc(mockAuth.currentUser!.uid)
//         .get();

//     expect(targetUserDoc.data()?['receivedRequests'],
//         isNot(contains('testUser123')));
//     expect(
//         currentUserDoc.data()?['sentRequests'], isNot(contains(targetUserId)));
//   });

//   test('Remove a friend', () async {
//     final targetUserId = 'friend202';

//     // Simulate adding as a friend
//     await friendRepo.sendFriendRequest(userId: targetUserId);
//     await friendRepo.acceptFriendRequest(userId: targetUserId);

//     // Remove friend
//     await friendRepo.removeFriend(userId: targetUserId);

//     final targetUserDoc =
//         await fakeFirestore.collection('users').doc(targetUserId).get();
//     final currentUserDoc = await fakeFirestore
//         .collection('users')
//         .doc(mockAuth.currentUser!.uid)
//         .get();

//     expect(targetUserDoc.data()?['friends'], isNot(contains('testUser123')));
//     expect(currentUserDoc.data()?['friends'], isNot(contains(targetUserId)));
//   });
// }
