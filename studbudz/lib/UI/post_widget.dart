import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/notifier.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

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
  
  int? participantCount;


  @override
  void initState() {
    super.initState();
    // Initiate media download when the widget is created
    if (widget.data['type'] == 'media' && widget.data['file'] != null) {
      _downloadMedia(widget.data['file']);
    } else if (widget.data['event_description'] != null) {
      widget.data['type'] = 'event';
      _downloadMedia(widget.data['event_image']);
      _handleGetParticipantCount();
    } else {
      widget.data['type'] = 'text';
    }

    // print("Post data: ${widget.data}");
  }
  Future<void> _handleGetParticipantCount()async {
    final eventId = widget.data['event_id'];
    final response = await Controller().engine.getParticipantsCount(eventID: eventId);
    print('andrew tate $response');
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            data['post_content'],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildMediaPost(dynamic data) {
    // print("building media post");
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
    final start = DateTime.parse(data['event_start_at']);
    final end = DateTime.parse(data['event_end_at']);
    final formattedTime =
        '${DateFormat.jm().format(start)}–${DateFormat.jm().format(end)}';
    final participants = data['participants_count'] ?? 0;


    // print('ANDREW TATE $data');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            data['subject'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // Description above the image
          Text(
            data['event_description'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),

          const SizedBox(height: 8),

          // Image with time & participants overlays
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _downloadedFile != null
                    ? Image.file(
                        File(_downloadedFile!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      )
                    : Image.asset(
                        'assets/dummyPost.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      ),
              ),
              // Time at bottom-left
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
              // Participants at bottom-right
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$participants',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Join button with participants count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  print('Joining event: ${data['subject']}');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Join'),
              ),
              const SizedBox(width: 12),
              Text(
                '$participants participating',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
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
    // print("avatar url: $url");
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);

      // print("downloaded avatar: ${file.path}");

      if (!mounted) return;

      setState(() {
        _avatarFile = file;
      });
    } else {
      // print("no avatar found");
      setState(() {
        _avatarFile = null;
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
              '${widget.data["username"]} ${widget.data["type"]}', // Placeholder for username (can be dynamic)
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
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
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.comment_outlined),
            //   iconSize: 30,
            // ),
            // // Share button
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.share_outlined),
            //   iconSize: 30,
            // ),
          ],
        ),
      ),
    );
  }
}
