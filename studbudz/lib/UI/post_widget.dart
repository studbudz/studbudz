import 'package:flutter/material.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      color: Colors.red,
      child: const Column(
        children: [
          PostHeader(),
          Image(
            image: AssetImage('assets/dummyPost.jpg'),
            width: 400,
            height: 400,
          ),
          ActionBar(),
        ],
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Image.asset(
            'assets/profileIcon.jpg',
            fit: BoxFit.cover,
          ),
        ),
        const Text('Username'),
        //username
        //time
        //... for report
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.favorite),
        Icon(Icons.comment),
        Icon(Icons.share),
      ],
    );
  }
}
