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
  int currentUserId = 0;

  bool isLoading = true;
  dynamic userData;
  List<dynamic> userPosts = [];
  String username = "john_doe";
  String bio = "Loving life. Photographer. Traveler.";
  int postsCount = 0;
  int followersCount = 0;
  List<dynamic>? posts = [];
  XFile? _avatarFile;

  bool following = false; // Track follow/unfollow state
  bool loadingFollow = false; // Track loading state for follow/unfollow

  bool get isCurrentUserProfile =>
      widget.userId == null || widget.userId == currentUserId;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    debugPrint("Fetching user data for user ID: ${widget.userId}");

    try {
      debugPrint("Attempting to fetch current user ID...");
      currentUserId = await Controller().engine.getUserId();
      debugPrint("Current user ID fetched: $currentUserId");

      debugPrint(
          "Fetching user profile for user ID: ${widget.userId ?? currentUserId}");
      final result = await Controller()
          .engine
          .getUserProfile(userID: widget.userId ?? currentUserId);

      debugPrint("User profile fetched successfully: $result");

      // Ensure the result contains the expected keys
      if (result.containsKey("user") && result.containsKey("posts")) {
        userData = result["user"];
        userPosts = result["posts"];
        debugPrint("User data: $userData");
        debugPrint("User posts: $userPosts");

        await _downloadAvatar();

        setState(() {
          username = userData["username"] ?? "Unknown User";
          bio = userData["user_bio"] ?? "No bio available.";
          followersCount = userData["followers_count"] ?? 0;
          postsCount = userPosts.length;
          posts = userPosts;
          following =
              userData["is_followed"] ?? false; // Initialize follow state
          isLoading = false;
        });
      } else {
        debugPrint("Error: Missing 'user' or 'posts' in the response.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _downloadAvatar() async {
    final url = userData['user_avatar'] as String?;
    print("avatar url: $url");
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
        _avatarFile = null;
      });
    }
  }

  Future<void> _handleFollow() async {
    setState(() => loadingFollow = true);
    final userId = widget.userId ?? currentUserId;

    try {
      if (!following) {
        debugPrint("Following user with ID: $userId");
        await Controller().engine.followUser(userId);
      } else {
        debugPrint("Unfollowing user with ID: $userId");
        await Controller().engine.unfollowUser(userId);
      }

      setState(() {
        following = !following;
        followersCount += following ? 1 : -1; // Update followers count
      });
    } catch (e) {
      debugPrint("Error during follow/unfollow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to ${following ? "unfollow" : "follow"} the user.'),
        ),
      );
    } finally {
      setState(() => loadingFollow = false);
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
        toolbarHeight: 40,
      ),
      body: Stack(
        children: [
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (!isLoading)
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: isCurrentUserProfile ? 40.0 : 0.0,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _avatarFile != null
                            ? FileImage(File(_avatarFile!.path))
                            : null,
                        child: _avatarFile == null
                            ? const Icon(Icons.person, size: 32)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bio,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStatsColumn(postsCount, 'Posts'),
                                const SizedBox(width: 24),
                                _buildStatsColumn(followersCount, 'Friends'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(fontSize: 14),
                        backgroundColor: isCurrentUserProfile || following
                            ? Colors.grey
                            : Colors.blue,
                      ),
                      onPressed: isCurrentUserProfile
                          ? () async {
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
                            }
                          : (loadingFollow ? null : _handleFollow),
                      child: loadingFollow
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isCurrentUserProfile
                              ? 'Edit Profile'
                              : (following ? 'Following' : 'Follow')),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  color: Colors.grey[100],
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: FeedWidget(
                    posts: posts ??
                        [const Center(child: Text('Nothing to see here'))],
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
}
