import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_group.dart';
import 'search_group.dart';
import 'package:scusocial/core/constants/firebase_constants.dart';
import 'group_members_page.dart';
import 'package:scusocial/services/firestore_service.dart';
import 'package:scusocial/services/auth_service.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            child: Text('View Members'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupMembersPage(groupId: group['id']),
                                ),
                              );
                            },
                          ),
                          // Leave Group Button
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              FirebaseFirestore.instance.collection('groups').doc(group['id']).update({
                                'members': FieldValue.arrayRemove([user.uid]),
                              });
                            },
                          ),
                          if (group['leader'] == user.uid)
                            IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: () {
                                FirebaseFirestore.instance.collection('groups').doc(group['id']).delete();
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