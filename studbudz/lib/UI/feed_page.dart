import 'package:flutter/material.dart';
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
    super.initState();
    getData();
  }

  List<Map<String, dynamic>> formatFeedData(Map<String, dynamic> response) {
    final List<Map<String, dynamic>> formatted = [];

    // Format followed posts
    for (var post in response['followed_posts'] ?? []) {
      final hasFile =
          post['post_url'] != null && post['post_url'].toString().isNotEmpty;
      formatted.add({
        'type': hasFile ? 'media' : 'text',
        'subject': post['subject_name'] ?? 'General',
        'post_content': post['post_content'],
        if (hasFile) 'file': post['post_url'],
        'post_private': post['post_private'] == 1,
        'username': post['username'] ?? '',
        'profile_image': post['profile_image'] ?? '',
      });
    }

    // Format new posts by non-followed users
    for (var post in response['new_posts'] ?? []) {
      final hasFile =
          post['post_url'] != null && post['post_url'].toString().isNotEmpty;
      formatted.add({
        'type': hasFile ? 'media' : 'text',
        'subject': post['subject_name'] ?? 'General',
        'post_content': post['post_content'],
        if (hasFile) 'file': post['post_url'],
        'post_private': post['post_private'] == 1,
        'username': post['username'] ?? '',
        'profile_image': post['profile_image'] ?? '',
      });
    }

    // Format suggested events
    for (var event in response['suggested_events'] ?? []) {
      formatted.add({
        'type': 'event',
        'subject': event['subject_name'] ?? 'General',
        'event_name': event['event_name'],
        'event_image': event['event_image'],
        'event_description': event['event_description'],
        'event_location_name': event['event_location_name'],
        'event_start_at': event['event_start_at'],
        'event_end_at': event['event_end_at'],
        'event_private': event['event_private'] == 1,
      });
    }

    // Format suggested users as user-type entries
    for (var user in response['suggested_users'] ?? []) {
      formatted.add({
        'type': 'user',
        'user_id': user['user_id'],
        'username': user['username'],
        'profile_image': user['profile_image'] ?? '',
      });
    }

    return formatted;
  }

  getData() async {
    final result = await Controller().engine.getFeed(page: 1);

    setState(() {
      data = formatFeedData(result);
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

class UserRecommendationWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserRecommendationWidget({super.key, required this.userData});

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
            backgroundImage: NetworkImage(userData['profile_image']),
            radius: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('@${userData['username']}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Follow'),
          )
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