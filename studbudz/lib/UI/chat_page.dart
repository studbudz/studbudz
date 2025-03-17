import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart'; // Import your NavBarWidget

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              // You can add your Chat content here
              Expanded(
                child: Center(
                  child: Text(
                    'Your Chats ', // Replace with actual chat content
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 20,
          child: NavBarWidget(), // Add NavBarWidget at the bottom
        ),
      ],
    );
  }
}
