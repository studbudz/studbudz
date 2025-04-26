import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/post_widget.dart';

//server needs to filter posts based on user's interests
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<String> widgets = [
    "post",
    "post",
    "post",
    "quickadd",
    "post",
    "post",
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: PostWidget(),
              );
            },
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: NavBarWidget(),
        ),
      ],
    );
  }
}
