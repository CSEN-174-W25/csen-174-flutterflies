import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user from FirebaseAuth and user info from the provider
    final user = FirebaseAuth.instance.currentUser;
    final userInfo = ref.watch(getUserInfoByIdProvider(userId));

    return userInfo.when(
      data: (userData) {
        // Check if first name is Tyler or Madeline
        final bool isTyler =
            userData.fullName.split(' ')[0].toLowerCase() == 'tyler';
        final bool isMadeline =
            userData.fullName.split(' ')[0].toLowerCase() == 'madeline';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Profile image - use appropriate image based on name
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: isTyler
                          ? AssetImage('assets/tyler.JPG')
                          : isMadeline
                              ? AssetImage('assets/maddie.jpg')
                              : AssetImage('assets/default_avatar.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userData.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bio: ${userData.bio ?? 'No bio available'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Year: ${userData.year ?? 'No year available'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (userData.uid == user?.uid)
                      ElevatedButton(
                        child: Text('Edit Profile'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  userId: userId,
                                ),
                              ));
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print("❌ Error loading profile: $error");
        return Scaffold(
          body: Center(child: Text('Error: $error')),
        );
      },
      loading: () {
        print("⏳ Loading user profile...");
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
