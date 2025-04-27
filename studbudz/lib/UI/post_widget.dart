import 'dart:io';
import 'package:flutter/material.dart';

class PostWidget extends StatefulWidget {
  final dynamic data;
  const PostWidget({super.key, this.data});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false; // Track the state of the heart icon

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
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
                isLiked = !isLiked; // Toggle the heart icon state
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
        return SizedBox.shrink();
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
          SizedBox(height: 8),
          Text(
            data['post_content'],
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildMediaPost(dynamic data) {
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
            data['post_content'],
            style: TextStyle(fontSize: 16),
          ),
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
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Location: ${data['event_location_name']}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Time: ${data['event_start_at']} - ${data['event_end_at']}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final dynamic data;
  const HeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 10),
          Text(
            'Username', // Placeholder for username (can be dynamic)
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              return {'Report', 'Block User'}
                  .map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
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
              icon: Icon(Icons.comment_outlined),
              iconSize: 30,
            ),
            // Share button
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.share_outlined),
              iconSize: 30,
            ),
          ],
        ),
      ),
    );
  }
}
