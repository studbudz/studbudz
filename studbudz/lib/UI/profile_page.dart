import 'package:flutter/material.dart';
import 'package:studubdz/UI/friends_page.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/settings_page.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "john_doe";
  String name = "John Doe";
  String bio = "Loving life. Photographer. Traveler.";
  final int postsCount = 34;
  final int followersCount = 1200;
  final int followingCount = 350;

  final List<String> posts = [
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    'assets/dummyPost.jpg',
    



  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsPage()));
              
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content (Profile details and posts)
          ListView(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profileIcon.jpg'),
                    ),
                    const SizedBox(width: 20),
                    // User Info (Username, Name, Stats)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(bio, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        // Stats (Posts, Followers, Following)
                        Row(
                          children: [
                            _buildStatsColumn(postsCount, 'Posts'),
                            _buildClickableStatsColumn(followersCount, 'Friends', context),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Edit Profile Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to the Edit Profile screen
                    final updatedProfile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(currentName: name, currentBio: bio),
                      ),
                    );

                    if (updatedProfile != null) {
                      setState(() {
                        name = updatedProfile['name'];
                        bio = updatedProfile['bio'];
                      });
                    }
                  },
                  child: const Text('Edit Profile'),
                ),
              ),

              const Divider(),

              // Posts Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 1,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // View post details or go to a detailed page
                    },
                    child: Image.network(posts[index], fit: BoxFit.cover),
                  );
                },
              ),
            ],
          ),
          // Add the NavBarWidget at the bottom of the screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0, // Ensure the NavBarWidget spans the full width
            child: NavBarWidget(), // Add your NavBarWidget here
          ),
        ],
      ),
    );
  }

  // Helper method to create Stats columns (Posts, Followers, Following)
  Widget _buildStatsColumn(int count, String label) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Helper method for creating clickable "Friends" column
  Widget _buildClickableStatsColumn(int count, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the FriendsPage when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsPage()),
        );
      },
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}