import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/notifier.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final dynamic data;
  const PostWidget({super.key, this.data});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false; // Track the state of the heart icon
  XFile? _downloadedFile;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    // Initiate media download when the widget is created
    if (widget.data['type'] == 'media') {
      _downloadMedia(widget.data['file']);
    }
  }

  Future<void> _downloadMedia(String url) async {
    if (url.isEmpty) return;
    final file = await Controller().engine.downloadMedia(endpoint: url);
    if (!mounted) return;
    setState(() {
      _downloadedFile = file;
      if (url.endsWith('.mp4')) {
        _videoController = VideoPlayerController.file(File(file.path))
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {});
            // Ensure audio is not muted
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          HeaderWidget(data: widget.data),
          buildMainSection(widget.data),
          FooterWidget(
            isLiked: isLiked,
            onLikePressed: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildMainSection(dynamic data) {
    String postType = data['type'];
    switch (postType) {
      case 'text':
        return buildTextPost(data);
      case 'media':
        return buildMediaPost(data);
      case 'event':
        return buildEventPost(data);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildTextPost(dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['subject'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            data['post_content'],
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildMediaPost(dynamic data) {
    final url = data['file'] as String?;
    Widget content;

    if (_videoController != null && _videoController!.value.isInitialized) {
      content = AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              if (!_videoController!.value.isPlaying)
                Container(
                  color: Colors.black45,
                  child: const Icon(
                    Icons.play_arrow,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (_downloadedFile != null) {
      content = Image.file(
        File(_downloadedFile!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
      );
    } else {
      content = Image.asset(
        'assets/dummyPost.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['subject'],
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          content,
          const SizedBox(height: 8),
          Text(data['post_content'], style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildEventPost(dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['subject'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Image.asset(
            'assets/dummyPost.jpg', // Use the image from assets
            fit: BoxFit.cover,
            width: double.infinity,
            height: 250,
          ),
          SizedBox(height: 8),
          Text(
            data['event_description'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Location: ${data['event_location_name']}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Time: ${data['event_start_at']} - ${data['event_end_at']}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class HeaderWidget extends StatefulWidget {
  final dynamic data;
  const HeaderWidget({super.key, required this.data});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  XFile? _avatarFile;

  @override
  void initState() {
    super.initState();
    _downloadAvatar();
  }

  Future<void> _downloadAvatar() async {
    final url = widget.data['user_avatar'] as String?;

    // If URL is not empty, try to download the avatar
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);

      // Check if the widget is still mounted before updating the state
      if (!mounted) return;

      setState(() {
        _avatarFile = file;
      });
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
                    ProfilePage(userId: widget.data['user_id'])));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
            const SizedBox(width: 10),
            Text(
              '${widget.data["username"]}', // Placeholder for username (can be dynamic)
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Report') {
                  print('Report clicked');
                } else if (value == 'Block User') {
                  print('Block User clicked');
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Report', 'Block User'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

class FooterWidget extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikePressed;

  const FooterWidget({
    super.key,
    required this.isLiked,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          children: [
            // Heart button with animation when pressed
            IconButton(
              onPressed: onLikePressed,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black54,
              ),
              iconSize: 30,
            ),
            // Comment button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.comment_outlined),
              iconSize: 30,
            ),
            // Share button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              iconSize: 30,
            ),
          ],
        ),
      ),
    );
  }
}
