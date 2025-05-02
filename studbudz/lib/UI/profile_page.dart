import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/feed_widget.dart';
import 'package:studubdz/UI/friends_page.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/settings_page.dart';
import 'package:studubdz/notifier.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage
import 'package:video_thumbnail/video_thumbnail.dart';

class ProfilePage extends StatefulWidget {
  final int? userId; // null means it's the current user
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUserId = Controller().engine.userId;
  bool isLoading = true;
  dynamic userData;
  List<dynamic> userPosts = [];
  String username = "john_doe";
  String bio = "Loving life. Photographer. Traveler.";
  int postsCount = 34;
  int followersCount = 1200;

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

      setState(() {
        username = userData["username"];
        bio = userData["user_bio"] ?? "";
        followersCount = userData["followers_count"] ?? 0;
        postsCount = userPosts.length;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(bio,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Row(
                        children: [
                          Text('$postsCount posts'),
                          SizedBox(width: 20),
                          Text('$followersCount followers'),
                        ],
                      ),
                    ],
                  ),
                ),
                FeedWidget(
                  posts: userPosts,
                  isLoading: isLoading,
                  onLoadMore: getUserData,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
