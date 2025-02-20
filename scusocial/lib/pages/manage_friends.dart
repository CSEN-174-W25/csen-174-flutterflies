import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/friends/friend-repo.dart';
import '../core/constants/firebase_constants.dart';

class ManageFriends extends StatefulWidget {
  @override
  _ManageFriendsState createState() => _ManageFriendsState();
}

class _ManageFriendsState extends State<ManageFriends> {
  late FriendRepository friendRepository;

  @override
  void initState() {
    super.initState();
    friendRepository = FriendRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  }

  Stream<List<String>> _getFriendRequests() {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    print('Fetching friend requests for user: $myUid');

    return FirebaseFirestore.instance
        .collection(FirebaseCollectionNames.friendRequests)
        .where(FirebaseFieldNames.to, isEqualTo: myUid)
        .where(FirebaseFieldNames.status, isEqualTo: "pending")
        .snapshots()
        .map((snapshot) {
      print(
          "Raw snapshot data: ${snapshot.docs.map((doc) => doc.data()).toList()}"); // Debugging line
      return snapshot.docs
          .map((doc) => doc[FirebaseFieldNames.from] as String)
          .toList();
    });
  }

  Future<void> _acceptRequest(String userId) async {
    print('Accepting friend request from $userId');
    await friendRepository.acceptFriendRequest(userId: userId);
  }

  Future<void> _declineRequest(String userId) async {
    print('Declining friend request from $userId');
    await friendRepository.declineFriendRequest(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Friends')),
      body: StreamBuilder<List<String>>(
        stream: _getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // print getfriendrequests data
            print('Friend requests data: ${snapshot.data}');

            return Center(child: Text('No friend requests.'));
          }

          List<String> friendRequests = snapshot.data!;

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              String userId = friendRequests[index];

              return ListTile(
                title: Text('User ID: $userId'),
                subtitle: Text('Wants to be your friend'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await _acceptRequest(userId);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await _declineRequest(userId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
