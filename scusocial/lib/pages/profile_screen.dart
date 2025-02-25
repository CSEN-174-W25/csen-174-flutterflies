import 'package:flutter/material.dart';
// have to install dependencies flutter pub add flutter_riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = FirebaseAuth.instance.currentUser!.displayName;
    final userPhoto = FirebaseAuth.instance.currentUser!.photoURL;
    final userInfo = ref.watch(getUserInfoByIdProvider(userId));

    return userInfo.when(
      data: (user) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userPhoto!),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print('Error: $error');
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        print('Loading...');
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
