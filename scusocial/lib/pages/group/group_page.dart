import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_group.dart';
import 'search_group.dart';
class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  // List<Map<String, dynamic>> _userGroups = [];
  // bool _isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _getUserGroups();
  // }

  // Future<void> _getUserGroups() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('groups')
  //         .where('members', arrayContains: user.uid)
  //         .get();

  //     setState(() {
  //       _userGroups = snapshot.docs
  //           .map((doc) => {
  //                 'id': doc.id,
  //                 ...doc.data() as Map<String, dynamic>,
  //               })
  //           .toList();
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchGroupPage(),
                ),
              );
            },
          ),
        ]
        ),
      // body: _isLoading
      //     ? Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //         itemCount: _userGroups.length,
      //         itemBuilder: (context, index) {
      //           final group = _userGroups[index];
      //           return ListTile(
      //             title: Text(group['name']),
      //             subtitle: Text(group['description']),
      //             onTap: () {
      //               // Navigate to group details page if needed
      //             },
      //           );
      //         },
      //       ),
      body: user == null
          ? Center(child: Text('Please log in to see your groups'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .where('members', arrayContains: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No groups found'));
                }

                final userGroups = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                        })
                    .toList();

                return ListView.builder(
                  itemCount: userGroups.length,
                  itemBuilder: (context, index) {
                    final group = userGroups[index];
                    return ListTile(
                      title: Text(group['name']),
                      subtitle: Text(group['description']),
                      onTap: () {
                        // Navigate to group details page if needed
                      },
                    );
                  },
                );
              },
            ),
    );  
  }
}