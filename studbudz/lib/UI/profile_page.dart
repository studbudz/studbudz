import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/feed_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/notifier.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage

class ProfilePage extends StatefulWidget {
  final int? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Simulated current user ID (in your app, replace this with real auth logic)
  final currentUserId = Controller().engine.userId;

  bool isLoading = true; // Add a loading flag
  dynamic userData;
  List<dynamic> userPosts = [];
  String username = "john_doe";
  String bio = "Loving life. Photographer. Traveler.";
  int postsCount = 34;
  int followersCount = 1200;
  List<String> posts = [];
  XFile? _avatarFile;

  bool get isCurrentUserProfile =>
      widget.userId == null || widget.userId == currentUserId;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final result = await Controller()
          .engine
          .getUserProfile(userID: widget.userId ?? currentUserId);

      userData = result["user"];
      userPosts = result["posts"];

      await _downloadAvatar();

      setState(() {
        username = userData["username"];
        bio = userData["user_bio"] ?? ""; // Ensure bio is safely assigned
        followersCount = userData["followers_count"] ??
            0; // Ensure this key exists in the result
        postsCount = userPosts.length;

        // Clear the posts list to avoid appending duplicates, then add new data
        posts.clear();
        posts.addAll(result['postUrls'] ??
            []); // Assuming postUrls contains URLs to the posts

        isLoading = false; // Set loading to false once data is loaded
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  Future<void> _downloadAvatar() async {
    final url = userData['user_avatar'] as String?;
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);

      print("downloaded avatar: ${file.path}");

      if (!mounted) return;

      setState(() {
        _avatarFile = file;
      });
    } else {
      print("no avatar found");
      setState(() {
        _avatarFile = null; // Set to null if no avatar is found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUserProfile ? '' : username),
        actions: [
          if (isCurrentUserProfile)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Controller().setPage(AppPage.settings);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(
                child:
                    CircularProgressIndicator()), // Show loading spinner while data loads
          if (!isLoading)
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _avatarFile != null
                            ? FileImage(File(_avatarFile!.path))
                            : null,
                        child: _avatarFile == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(bio,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatsColumn(postsCount, 'Posts'),
                                _buildClickableStatsColumn(
                                    followersCount, 'Friends', context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isCurrentUserProfile) {
                        final updatedProfile = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                                currentName: username, currentBio: bio),
                          ),
                        );

                        if (updatedProfile != null) {
                          setState(() {
                            username = updatedProfile['name'];
                            bio = updatedProfile['bio'];
                          });
                        }
                      } else {
                        // Add follow/unfollow logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Followed user (simulated)')),
                        );
                      }
                    },
                    child:
                        Text(isCurrentUserProfile ? 'Edit Profile' : 'Follow'),
                  ),
                ),
                Container(
                  color: Colors.grey[100], // Or any color you like
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: FeedWidget(
                    posts: posts,
                    isLoading: isLoading,
                    onLoadMore: () => {},
                  ),
                ),
              ],
            ),
          if (isCurrentUserProfile)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: NavBarWidget(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(int count, String label) {
    return Column(
      children: [
        Text('$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildClickableStatsColumn(
      int count, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Controller().setPage(AppPage.friendsPage);
      },
      child: Column(
        children: [
          Text('$count',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
