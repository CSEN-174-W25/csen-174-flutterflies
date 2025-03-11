import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/friends/friend-repo.dart';
import '../core/constants/firebase_constants.dart';
import '../features/friends/get_user_info_by_id_provider.dart';
import '../features/friends/search_user_screen.dart';
import '../pages/profile_screen.dart';

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

  Stream<List<String>> _getFriends(String userId) {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    print('Getting friends for user: $userId');
    return friendRepository.getFriends(userId: myUid);
  }

  @override
  Widget build(BuildContext context) {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    //final userInfo = ref.watch(getUserInfoByIdProvider(myUid));
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: Theme.of(context).cardColor),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUserScreen(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('Manage Friends'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Friend Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _getFriendRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print('Friend requests data: ${snapshot.data}');
                  return Center(child: Text('No friend requests.'));
                }

                List<String> friendRequests = snapshot.data!;

                return ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    String userId = friendRequests[index];

                    return Consumer(
                      builder: (context, ref, child) {
                        final userInfo = ref.watch(getUserInfoByIdProvider(userId));

                        return userInfo.when(
                          data: (user) {
                            return ListTile(
                              title: Text(user.fullName),
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
                          error: (error, stackTrace) {
                            return ListTile(
                              title: Text('Error loading user info'),
                            );
                          },
                          loading: () {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Friends List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _getFriends(myUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No friends found'));
                }

                List<String> friends = snapshot.data!;

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    String friendId = friends[index];

                    return Consumer(
                      builder: (context, ref, child) {
                        final userInfo = ref.watch(getUserInfoByIdProvider(friendId));

                        return userInfo.when(
                          data: (user) {
                            return ListTile(
                              title: Text(user.fullName),
                              //subtitle: Text(user.bio ?? 'No bio available'),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  friendRepository.removeFriend(userId: user.uid);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context)=>ProfileScreen(userId: user.uid),
                                  ),
                                );
                              }
                            );
                          },
                          error: (error, stackTrace) {
                            return ListTile(
                              title: Text('Error loading user info'),
                            );
                          },
                          loading: () {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
