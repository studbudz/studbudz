import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  final List<Map<String, String>> friends = const [
    {
      'username': '@alice_j',
      'image': 'assets/profileIcon.jpg',
    },
    {
      'username': '@bob_smith',
      'image': 'assets/profileIcon.jpg',
    },
    {
      'username': '@catlee',
      'image': 'assets/profileIcon.jpg',
    },
    {
      'username': '@davidk',
      'image': 'assets/profileIcon.jpg',
    },
    {
      'username': '@emilyd',
      'image': 'assets/profileIcon.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend['image']!),
              radius: 25,
            ),
            title: Text(friend['username']!),
          );
        },
      ),
    );
  }
}
