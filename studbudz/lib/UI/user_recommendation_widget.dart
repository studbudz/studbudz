import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/notifier.dart';

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
  XFile? _avatarFile;
  bool following = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _downloadAvatar();
    print("userData: ${widget.userData}");
    following = widget.userData['is_followed'] ?? false;
  }

  Future<void> _downloadAvatar() async {
    final url = widget.userData['user_avatar'] as String?;
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);
      if (!mounted) return;
      setState(() {
        _avatarFile = file;
      });
    }
  }

  Future<void> _handleFollow() async {
    setState(() => loading = true);
    final userId = widget.userData['user_id'];
    try {
      if (!following) {
        print("follwing $userId");
        await Controller().engine.followUser(userId);
      } else {
        await Controller().engine.unfollowUser(userId);
      }
      setState(() => following = !following);
      // Optionally notify parent to refresh feed
      if (widget.onFollowChanged != null) widget.onFollowChanged!();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to ${following ? "unfollow" : "follow"} user')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfilePage(userId: widget.userData['user_id']),
          ),
        );
      },
      child: Container(
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
                  : const Icon(Icons.person, size: 25, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('@${widget.userData['username']}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
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
