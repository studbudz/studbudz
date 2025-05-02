import 'package:flutter/material.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/user_recommendation_widget.dart';

class FeedWidget extends StatefulWidget {
  final List<dynamic> posts;
  final bool isLoading;
  final void Function() onLoadMore;

  const FeedWidget({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 20),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final item = widget.posts[index];
        if (item['type'] == 'user') {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: UserRecommendationWidget(userData: item),
          );
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: PostWidget(data: item),
          );
        }
      },
    );
  }
}
