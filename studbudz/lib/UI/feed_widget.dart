import 'package:flutter/material.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/user_recommendation_widget.dart';

// A scrollable widget that displays a mixed feed of posts and user recommendations.
//
// Parameters:
//   - posts: List of dynamic data containing both posts and user recommendations
//   - isLoading: Flag indicating if content is currently loading
//   - onLoadMore: Callback to trigger loading of additional content
//
class FeedWidget extends StatefulWidget {
  // Builds the feed layout with appropriate spacing and content rendering
  //
  // - Uses SingleChildScrollView for scrollable content
  // - Maps each feed item to either PostWidget or UserRecommendationWidget
  // - Maintains consistent padding for all feed items
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, top: 20),
      child: Column(
        children: widget.posts.map((item) {
          // User recommendations are identified by 'user' type field
          if (item['type'] == 'user') {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: UserRecommendationWidget(userData: item),
            );
          }
          // All other items are treated as standard posts
          else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: PostWidget(data: item),
            );
          }
        }).toList(),
      ),
    );
  }
}
