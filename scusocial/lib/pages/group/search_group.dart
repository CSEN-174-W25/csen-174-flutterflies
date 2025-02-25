import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './join_group.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchGroupPage extends StatefulWidget {
  @override
  _SearchGroupPageState createState() => _SearchGroupPageState();
}

class _SearchGroupPageState extends State<SearchGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _joinGroup(BuildContext context, String groupId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }


  Future<void> _searchGroups(String query) async {
    setState(() {
      _isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _searchResults = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Groups')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Group Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  _searchGroups(query.trim());
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final group = _searchResults[index];
                        return ListTile(
                          title: Text(group['name']),
                          subtitle: Text(group['description']),
                          trailing: TextButton (
                              onPressed: () => _joinGroup(context, group['id']),
                              child: Text('Request to Join'),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
