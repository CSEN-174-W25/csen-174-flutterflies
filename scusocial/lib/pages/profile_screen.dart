import 'package:flutter/material.dart';
// have to install dependencies flutter pub add flutter_riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:scusocial/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId,});

  final String userId;

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final userInfo = ref.watch(getUserInfoByIdProvider(userId));

    return userInfo.when(
      data: (user) {
        return SafeArea(child: 
        Center(
          child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  //backgroundImage: NetworkImage(user.profilePicUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  //should be user full name
                  user.uid,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   child: Text('Friend List'), 
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const SearchUserScreen(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
          ),
        )
        );
      },
      error: (error, stackTrace) {
        print('Error: $error');
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        print('Loading...');
        return Center(child: Text('Loading...'));
      },
    );
  }
}
