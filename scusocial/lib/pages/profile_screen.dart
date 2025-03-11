import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scusocial/features/friends/get_user_info_by_id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'edit_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;
  static const routeName = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isRetrying = false;
  String? _photoUrl;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
  }

  Future<bool> checkImageAvailability(String url) async {
    try {
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❗ Error checking image: $e");
      return false;
    }
  }

  String getFormattedPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Google Photos typically use =s96-c format
    // Check if it already has a size parameter
    if (url.contains('=s')) {
      // Replace existing size with your desired size
      return url.replaceAll(RegExp(r'=s\d+-c'), '=s200-c');
    } else if (url.contains('?')) {
      return '$url&sz=200';
    } else {
      return '$url?sz=200';
    }
  }

  String getOriginalUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Remove any size parameters
    if (url.contains('=s')) {
      return url.replaceAll(RegExp(r'=s\d+-c'), '');
    } else if (url.contains('?sz=')) {
      return url.replaceAll(RegExp(r'\?sz=\d+'), '');
    } else if (url.contains('&sz=')) {
      return url.replaceAll(RegExp(r'&sz=\d+'), '');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(getUserInfoByIdProvider(widget.userId));

    return userInfo.when(
      data: (userData) {
        final formattedPhotoUrl = getFormattedPhotoUrl(_photoUrl ?? '');
        final originalPhotoUrl = getOriginalUrl(_photoUrl ?? '');

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
                    // Profile image with fallback strategy
                    FutureBuilder<bool>(
                      // Check image availability only once
                      future: _imageLoaded
                          ? Future.value(true)
                          : checkImageAvailability(formattedPhotoUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !_imageLoaded) {
                          return const CircleAvatar(
                            radius: 50,
                            child: CircularProgressIndicator(),
                          );
                        }

                        final bool imageAvailable = snapshot.data ?? false;

                        if (imageAvailable) {
                          _imageLoaded = true;
                          return Image.network(
                            formattedPhotoUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return ClipOval(child: child);
                              }
                              return const CircleAvatar(
                                radius: 50,
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  "🚨 Image failed to load: $formattedPhotoUrl");

                              // Try with the original URL without size parameters
                              return Image.network(
                                originalPhotoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return ClipOval(child: child);
                                  }
                                  return const CircleAvatar(
                                    radius: 50,
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // Final fallback is the default avatar
                                  return const CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        AssetImage('assets/default_avatar.png'),
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          // Try with original URL if formatted URL is not available
                          return Image.network(
                            originalPhotoUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return ClipOval(child: child);
                              }
                              return const CircleAvatar(
                                radius: 50,
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Final fallback is the default avatar
                              return const CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    AssetImage('assets/default_avatar.png'),
                              );
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ??
                          'Unknown User',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Text('Edit Profile'),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                    userId: widget.userId,
                                  ),
                                ));
                          },
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _isRetrying = true;
                              _imageLoaded = false;
                            });

                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              setState(() {
                                _isRetrying = false;
                              });
                            });
                          },
                          tooltip: 'Retry loading profile image',
                        ),
                      ],
                    ),
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
