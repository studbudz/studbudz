import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/notifier.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

// Displays a single post (text, media, or event) with interactive features such as like, join/leave event, and user profile navigation.
// Handles media downloading, video playback, and participant count updates.
//
// Parameters:
//   - data: dynamic. The post data map containing post type, content, and metadata.
class PostWidget extends StatefulWidget {
  final dynamic data;
  const PostWidget({super.key, this.data});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false; // Track the state of the heart icon
  bool hasJoined = false; // Track if the user has joined the event
  XFile? _downloadedFile;
  VideoPlayerController? _videoController;

  int? participantCount;

  // Initializes post state, downloads media if needed, and checks like/join status.
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
      _handleHasJoined();
    } else {
      widget.data['type'] = 'text';
    }

    // Check if the post is liked
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final postId = widget.data['post_id'];

    try {
      final liked = await Controller().engine.hasLikedPost(postID: postId);
      print("post was liked? $liked");
      setState(() {
        isLiked = liked;
      });
    } catch (e) {
      print("Error checking if post is liked: $e");
    }
  }

  // Fetches and updates the number of participants for an event post.
  Future<void> _handleGetParticipantCount() async {
    final eventId = widget.data['event_id'];

    final response =
        await Controller().engine.getParticipantsCount(eventID: eventId);

    setState(() {
      participantCount = response['participant_count'];
    });
  }

// Toggles the like state for the post and updates backend.
  Future<void> _handleToggleLike() async {
    print(widget.data);
    final postId = widget.data['post_id'];

    try {
      if (isLiked) {
        print("Unliking post with ID: $postId");
        await Controller().engine.unlikePost(postID: postId);
      } else {
        print("Liking post with ID: $postId");
        await Controller().engine.likePost(postID: postId);
      }

      setState(() {
        isLiked = !isLiked; // Toggle the like state
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status.')),
      );
    }
  }

  // Checks if the user has joined the event (for event posts)
  Future<void> _handleHasJoined() async {
    final eventId = widget.data['event_id'];

    print("Checking if user has joined event with ID: $eventId");

    final joined = await Controller().engine.hasJoinedEvent(eventID: eventId);

    setState(() {
      hasJoined = joined;
    });
  }

  // Handles join/leave event logic and updates participant count.
  Future<void> _handleToggleJoinEvent() async {
    final eventId = widget.data['event_id'];

    try {
      if (hasJoined) {
        print("Leaving event with ID: $eventId");
        await Controller().engine.handleLeaveEvent(eventID: eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the event!')),
        );
      } else {
        print("Joining event with ID: $eventId");
        await Controller().engine.handleJoinEvent(eventID: eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the event!')),
        );
      }

      setState(() {
        hasJoined = !hasJoined; // Toggle the state
        participantCount = hasJoined
            ? (participantCount ?? 0) + 1
            : (participantCount ?? 0) - 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update event participation.')),
      );
    }
  }

  // Downloads media file (image/video) for the post and initializes video controller if needed.
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

  // Builds the main post UI, including header, content, and footer.
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
            onLikePressed: _handleToggleLike,
          ),
        ],
      ),
    );
  }

  // Renders the appropriate post content widget based on post type.
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

// Renders a text post with subject and content.
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

  // Renders a media post, supporting both images and videos.
  // Handles video playback toggle on tap.
  Widget buildMediaPost(dynamic data) {
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

  // Renders an event post with subject, description, image, time, participants, and join/leave button.
  Widget buildEventPost(dynamic data) {
    final start = DateTime.parse(data['event_start_at']);
    final end = DateTime.parse(data['event_end_at']);
    final formattedTime =
        '${DateFormat.jm().format(start)}–${DateFormat.jm().format(end)}';
    final participants = participantCount ?? 0;

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

          // Join/Leave button with participants count
          Center(
            child: ElevatedButton(
              onPressed: _handleToggleJoinEvent,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: Text(hasJoined ? 'Leave' : 'Join'),
            ),
          ),
        ],
      ),
    );
  }
}

// Displays the post header with user avatar, username, and a popup menu for actions (e.g., report/block).
//
// Parameters:
//   - data: dynamic. The post/user data.
class HeaderWidget extends StatefulWidget {
  final dynamic data;
  const HeaderWidget({super.key, required this.data});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  XFile? _avatarFile;
  // Downloads the user's avatar image if a URL is provided.
  @override
  void initState() {
    super.initState();
    _downloadAvatar();
  }

  Future<void> _downloadAvatar() async {
    final url = widget.data['user_avatar'] as String?;
    if (url != null && url.isNotEmpty) {
      final file = await Controller().engine.downloadMedia(endpoint: url);

      if (!mounted) return;

      setState(() {
        _avatarFile = file;
      });
    } else {
      setState(() {
        _avatarFile = null;
      });
    }
  }

  // Builds the header UI, including avatar, username, and menu.
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
                      Icons.person,
                      size: 25,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 10),
            Text(
              '${widget.data["username"]}',
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

// Displays the footer of a post, including the like button.
//
// Parameters:
//   - isLiked: bool. Whether the post is currently liked.
//   - onLikePressed: VoidCallback. Called when the like button is pressed.
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
            IconButton(
              onPressed: onLikePressed,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black54, // Red if liked
              ),
              iconSize: 30,
            ),
          ],
        ),
      ),
    );
  }
}
