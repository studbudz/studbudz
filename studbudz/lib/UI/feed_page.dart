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
    checkAuthenticationAndLoadData();
  }

  Future<void> checkAuthenticationAndLoadData() async {
    try {
      final loggedIn = await Controller().engine.isLoggedIn();
      if (!loggedIn) {
        print("Not logged in. Redirecting to login.");
        Controller().setPage(AppPage.signIn);
        return;
      }

      print("Token found. Fetching feed data.");
      await getData();
    } catch (e) {
      print("Error in checkAuthenticationAndLoadData: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> getData() async {
    final result = await Controller().engine.getFeed(page: 1);
    print("length: ${result["posts"].length}");

    if (!mounted) return;

    setState(() {
      data = result["posts"];
      isLoading = false;
    });
    print(data);
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
