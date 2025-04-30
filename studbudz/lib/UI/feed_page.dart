import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/notifier.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  dynamic data = [];
  bool isLoading = true;

  @override
  void initState() {
    if (!mounted) return;

    super.initState();
    getData();
  }

  getData() async {
    final result = await Controller().engine.getFeed(page: 1);
    print("length: ${result["posts"].length}");

    if (!mounted) return;

    setState(() {
      data = result["posts"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Positioned.fill(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100, top: 20),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  print("current item: $item");
                  if (item['type'] == 'user') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: UserRecommendationWidget(
                          userData: item), // custom widget
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: PostWidget(data: item),
                    );
                  }
                },
              ),
            ),
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
}

class UserRecommendationWidget extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserRecommendationWidget({super.key, required this.userData});

  @override
  State<UserRecommendationWidget> createState() =>
      _UserRecommendationWidgetState();
}

class _UserRecommendationWidgetState extends State<UserRecommendationWidget> {
  XFile? _avatarFile;

  @override
  void initState() {
    super.initState();
    _downloadAvatar();
  }

  Future<void> _downloadAvatar() async {
    final url = widget.userData['user_avatar'] as String?;

    // If URL is not empty, try to download the avatar
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);

      if (!mounted) return;

      setState(() {
        _avatarFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: _avatarFile != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(_avatarFile!.path)),
                    radius: 25,
                  )
                : const Icon(
                    Icons.person, // Default user icon
                    size: 25,
                    color: Colors.white, // Icon color
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('@${widget.userData['username']}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}

// List<dynamic> data = [
  //   // Text post
  //   {
  //     'type': 'text',
  //     'subject': 'Exploring Quantum Mechanics',
  //     'post_content':
  //         'Quantum mechanics challenges our understanding of reality, where particles can exist in multiple states at once. Let\'s explore the weirdness of the quantum world together.',
  //     'post_private': false, // Public post
  //   },
  //   // Media post (e.g., an image post)
  //   {
  //     'type': 'media',
  //     'subject': 'Sunset Photography',
  //     'file': 'sunset_image.jpg', // Path to an image file or URL
  //     'post_content':
  //         'Captured the beauty of a sunset on the beach. The colors were mesmerizing!',
  //     'post_private': true, // Private post
  //   },
  //   // Event post
  //   {
  //     'type': 'event',
  //     'subject': 'Astronomy Club Meetup',
  //     'event_name': 'Stargazing Night at the Observatory',
  //     'event_image': 'stargazing_image.jpg', // Path to an event image
  //     'event_description':
  //         'Join us for an exciting stargazing session at the local observatory. We’ll be observing planets, stars, and other celestial objects through high-powered telescopes.',
  //     'event_location_name': 'Lunar Observatory, Downtown',
  //     'event_start_at': DateTime.parse('2025-05-01 19:00:00').toIso8601String(),
  //     'event_end_at': DateTime.parse('2025-05-01 23:00:00').toIso8601String(),
  //     'event_private': false, // Public event
  //   }
  // ];