import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'edit_profile.dart';
import 'dart:io';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;
  static const routeName = '/profile';

  Future<void> logImageStatus(String? url) async {
    if (url == null || url.isEmpty) {
      print("⚠️ Profile photo URL is empty or null.");
      return;
    }

    print("🖼️ Fetching profile image from: $url");

    try {
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      print("📡 Image request status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("❌ Failed to load image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❗ Error fetching image: $e");
    }
  }

  String getFormattedPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.contains('?') ? url : '$url?sz=200';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    final userInfo = ref.watch(getUserInfoByIdProvider(userId));

    return userInfo.when(
      data: (userData) {
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
                    CachedNetworkImage(
                      imageUrl: getFormattedPhotoUrl(photoUrl),
                      cacheManager: DefaultCacheManager(),
                      cacheKey: photoUrl, // Add a unique cache key
                      httpHeaders: {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                      },
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) {
                        print("⌛ Loading image: $url");
                        return const CircleAvatar(
                          radius: 50,
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        print("🚨 Image failed to load: $url, Error: $error");
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/default_avatar.png'),
                          child: Text(
                            'Error',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? 'Unknown User',
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
                    ElevatedButton(
                      child: Text('Edit Profile'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              userId: userId,
                            ),
                          )
                        );
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
