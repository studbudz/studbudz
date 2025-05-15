import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/notifier.dart';

// Parameters:
//   - userData: Map containing user details (user_id, username, user_avatar, is_followed)
//   - onFollowChanged: Optional callback triggered after successful follow/unfollow

class UserRecommendationWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onFollowChanged;

  const UserRecommendationWidget({
    super.key,
    required this.userData,
    this.onFollowChanged,
  });

  @override
  State<UserRecommendationWidget> createState() =>
      _UserRecommendationWidgetState();
}

class _UserRecommendationWidgetState extends State<UserRecommendationWidget> {
  XFile? _avatarFile; // Local cache for downloaded avatar
  bool following = false; // Current follow state
  bool loading = false; // Loading state for follow operations

  // Initializes component state:
  // 1. Downloads user avatar if available
  // 2. Sets initial follow state from userData
  @override
  void initState() {
    super.initState();
    _downloadAvatar();
    following = widget.userData['is_followed'] ?? false;
  }

  // Downloads user avatar from URL in userData
  // Uses Controller().engine.downloadMedia for backend integration
  Future<void> _downloadAvatar() async {
    final url = widget.userData['user_avatar'] as String?;
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);
      if (!mounted) return;
      setState(() => _avatarFile = file);
    }
  }

  // Handles follow/unfollow logic:
  // 1. Toggles loading state
  // 2. Calls appropriate engine method
  // 3. Updates local state
  // 4. Triggers optional parent callback
  // 5. Handles errors with SnackBar feedback
  Future<void> _handleFollow() async {
    setState(() => loading = true);
    final userId = widget.userData['user_id'];

    try {
      if (!following) {
        await Controller().engine.followUser(userId);
      } else {
        await Controller().engine.unfollowUser(userId);
      }

      setState(() => following = !following);
      widget.onFollowChanged?.call(); // Notify parent of changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${following ? "unfollow" : "follow"} user'),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // Builds the recommendation card UI:
  // - Tapable area for profile navigation
  // - Avatar display with fallback icon
  // - Username display
  // - Follow/unfollow button with loading state
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: widget.userData['user_id']),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User avatar with cached image or fallback
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: _avatarFile != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(_avatarFile!.path)),
                      radius: 25,
                    )
                  : const Icon(Icons.person, size: 25, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Username display
            Expanded(
              child: Text('@${widget.userData['username']}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            // Follow button with state management
            ElevatedButton(
              onPressed: loading ? null : _handleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: following ? Colors.grey : Colors.blue,
              ),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(following ? "Following" : "Follow"),
            ),
          ],
        ),
      ),
    );
  }
}
