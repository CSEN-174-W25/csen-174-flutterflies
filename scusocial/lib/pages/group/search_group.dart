import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchGroupPage extends StatefulWidget {
  @override
  _SearchGroupPageState createState() => _SearchGroupPageState();
}
// _SearchGroupPageState handles state for the SearchGroupPage widget.
class _SearchGroupPageState extends State<SearchGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  // _joinGroup method updates Firestore to add current user to the group members list.
  Future<void> _joinGroup(BuildContext context, String groupId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have joined the group')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to join a group')),
      );
    }
  }

  // _searchGroups method takes a query string and searches Firestore for groups with names matching the query
  Future<void> _searchGroups(String query) async {
    setState(() {
      _isLoading = true;
    });
    // Perform a search in Firestore for groups with names that match the query
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    // Map the results to a list of maps containing group data
    setState(() {
      _searchResults = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
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
            // TextField for user to input search query
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
            // Will display group search results or a loading indicator
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
