import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';

class GroupMembersPage extends ConsumerWidget {
  final String groupId;
  const GroupMembersPage({super.key, required this.groupId});
  
  Stream<List<String>> getGroupMembers() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['members']);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
      ),
      body: StreamBuilder<List<String>>(
        stream: getGroupMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No members found'));
          }

          final members = snapshot.data!;
          print('Members: $members'); // Debugging statement

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final memberId = members[index];
              final userInfo = ref.watch(getUserInfoByIdProvider(memberId));

              return userInfo.when(
                data: (user) {
                  print('User: ${user.fullName}'); // Debugging statement
                  return ListTile(
                    title: Text(user.fullName),
                  );
                },
                loading: () {
                  print('Loading user info for $memberId'); // Debugging statement
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                },
                error: (error, stackTrace) {
                  print('Error loading user info for $memberId: $error'); // Debugging statement
                  return ListTile(
                    title: Text('Error loading user info'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}