import 'package:flutter/material.dart';
import 'package:studubdz/UI/feed_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/notifier.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  dynamic data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final result = await Controller().engine.getFeed(page: 1);
    print("length: ${result["posts"].length}");

    if (!mounted) return;

    setState(() {
      data = result["posts"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Positioned.fill(
              child: FeedWidget(
                posts: data,
                isLoading: isLoading,
                onLoadMore: getData,
              ),
            ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: NavBarWidget(),
          ),
        ],
      ),
    );
  }
}
