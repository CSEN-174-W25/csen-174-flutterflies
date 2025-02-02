import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/add_friend_button.dart';
import 'package:scusocial/pages/error_page.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:scusocial/pages/loader.dart';
import 'package:scusocial/pages/profile_setup_form.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});

  final String? userId;

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final uid = userId?.isNotEmpty == true ? userId : myUid;

    if (uid == null) {
      print('[DEBUG] User ID is null');
      return const ErrorScreen(error: 'User ID not found.');
    }

    print('[DEBUG] Fetching user data for UID: $uid');
    final userInfo = ref.watch(getUserInfoByIdProvider(uid));

    return userInfo.when(
      data: (user) {
        print('[DEBUG] Retrieved user data: $user');

        // ✅ If user data is still null, try refreshing once
        if (user == null || user.fullName == null) {
          print('[ERROR] User data is null or incomplete!');

          // Refresh Firestore data to ensure it updates
          Future.delayed(Duration(milliseconds: 500), () {
            ref.refresh(getUserInfoByIdProvider(uid));
          });

          return ProfileSetupForm(uid: uid);
        }

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    user.fullName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (userId != myUid) AddFriendButton(user: user),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print('[ERROR] Fetching user data failed: $error');
        print('[STACKTRACE] $stackTrace');
        return ErrorScreen(error: error.toString());
      },
      loading: () {
        print('[DEBUG] Loading user data...');
        return const Loader();
      },
    );
  }
}
