import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/post_widget.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<dynamic> data = [
    // Text post
    {
      'type': 'text',
      'subject': 'Exploring Quantum Mechanics',
      'post_content': 'Quantum mechanics challenges our understanding of reality, where particles can exist in multiple states at once. Let\'s explore the weirdness of the quantum world together.',
      'post_private': false, // Public post
    },
    // Media post (e.g., an image post)
    {
      'type': 'media',
      'subject': 'Sunset Photography',
      'file': 'sunset_image.jpg', // Path to an image file or URL
      'post_content': 'Captured the beauty of a sunset on the beach. The colors were mesmerizing!',
      'post_private': true, // Private post
    },
    // Event post
    {
      'type': 'event',
      'subject': 'Astronomy Club Meetup',
      'event_name': 'Stargazing Night at the Observatory',
      'event_image': 'stargazing_image.jpg', // Path to an event image
      'event_description': 'Join us for an exciting stargazing session at the local observatory. We’ll be observing planets, stars, and other celestial objects through high-powered telescopes.',
      'event_location_name': 'Lunar Observatory, Downtown',
      'event_start_at': DateTime.parse('2025-05-01 19:00:00').toIso8601String(),
      'event_end_at': DateTime.parse('2025-05-01 23:00:00').toIso8601String(),
      'event_private': false, // Public event
    }
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // avoid nav bar overlap
              itemCount: data.length,
              itemBuilder: (context, index) {
                
                return  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: PostWidget(data: data[index]),
                );
              },
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavBarWidget(),
          ),
        ],
      ),
    );
  }
}
