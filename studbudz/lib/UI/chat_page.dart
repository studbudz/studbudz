import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:studubdz/UI/nav_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Random _random = Random();

  DateTime getRandomTime() {
    return DateTime.now().subtract(Duration(
      days: _random.nextInt(7),
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
    ));
  }

  late List<Map<String, dynamic>> dms;
  late List<Map<String, dynamic>> groups;

  @override
  void initState() {
    super.initState();

    dms = [
      {
        'name': 'Alice',
        'lastMessage': 'Hey! You free later?',
        'timestamp': getRandomTime(),
        'pinned': false,
      },
      {
        'name': 'Bob',
        'lastMessage': 'Got the notes?',
        'timestamp': getRandomTime(),
        'pinned': true,
      },
    ];

    groups = [
      {
        'name': 'Study Group A',
        'lastMessage': 'Meet at 4PM?',
        'timestamp': getRandomTime(),
        'pinned': false,
      },
      {
        'name': 'Design Team',
        'lastMessage': 'Mockups ready!',
        'timestamp': getRandomTime(),
        'pinned': false,
      },
    ];
  }

  List<Map<String, dynamic>> sortChats(List<Map<String, dynamic>> chats) {
    chats.sort((a, b) {
      if (a['pinned'] && !b['pinned']) return -1;
      if (!a['pinned'] && b['pinned']) return 1;
      return b['timestamp'].compareTo(a['timestamp']);
    });
    return chats;
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (msgDate == today) {
      return DateFormat.Hm().format(timestamp);
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat.E().format(timestamp);
    } else {
      return DateFormat.yMd().format(timestamp);
    }
  }

  void deleteChat(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Widget buildChatTile(Map<String, dynamic> chat, List<Map<String, dynamic>> list, int index) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => deleteChat(list, index),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/profileIcon.jpg'),
        ),
        title: Text(chat['name']),
        subtitle: Text(chat['lastMessage']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatTimestamp(chat['timestamp']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            IconButton(
              icon: Icon(
                chat['pinned'] ? Icons.push_pin : Icons.push_pin_outlined,
                color: chat['pinned'] ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  chat['pinned'] = !chat['pinned'];
                });
              },
            ),
          ],
        ),
        onTap: () {
          // Open chat screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 70.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chats',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("New Chat"),
                            content: const Text("Who do you want to start a new chat with?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Search Friends List"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Direct Messages
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Direct Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ...sortChats(dms).asMap().entries.map((entry) {
                return buildChatTile(entry.value, dms, entry.key);
              }),

              const SizedBox(height: 20),

              // Group Chats
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Group Chats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ...sortChats(groups).asMap().entries.map((entry) {
                return buildChatTile(entry.value, groups, entry.key);
              }),
            ],
          ),

          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavBarWidget(),
          ),
        ],
      ),
    );
  }
}