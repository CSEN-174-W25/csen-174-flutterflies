import 'package:scusocial/features/friends/add_friend_button.dart';
import 'package:scusocial/pages/error_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:scusocial/pages/loader.dart';
// have to install dependencies flutter pub add flutter_riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId,});

  final String? userId;

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final uid = userId ?? myUid;
    if (uid == null) {
      print('user id null');
    }
    final userInfo = ref.watch(getUserInfoByIdProvider(uid));

    return userInfo.when(
      data: (user) {
        return SafeArea(child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                  //NetworkImage(user.profilePicUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 20),
                if (userId != myUid) AddFriendButton(
                  user: user,
                ),
                //for later when we add user profile info 
                //const SizedBox(height: 20),
                // _buildProfileInfo(username: user.username),
              ],
            ),
          ),
          ),
        );
      },
      error: (error, stackTrace) {
        return ErrorScreen(error: error.toString());
      },
      loading: () {
        return const Loader();
      },
    );
  }

  // _AddFriendButton() => FilledButton(onPressed: () {}, child: const Text('Add Friend') );

  //for later use when we add info to a user profile
  // _buildProfileInfo({
  //   required String username,
  // })

}
