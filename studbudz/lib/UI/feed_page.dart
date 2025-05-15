import 'package:flutter/material.dart';
import 'package:studubdz/UI/feed_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/notifier.dart';

// A stateful page that displays the user's feed, including posts and recommendations.
//
// - Checks authentication on load and redirects to sign-in if not logged in.
// - Fetches feed data from the backend and displays it in a scrollable list.
// - Shows a loading spinner while fetching data.
// - Integrates with the app's navigation bar.
//
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Holds the list of posts and recommendations fetched from the backend.
  dynamic data = [];
  // Indicates whether the feed is currently loading.
  bool isLoading = true;
  // Called when the widget is inserted into the widget tree.
  // Checks authentication and loads feed data if logged in.
  @override
  void initState() {
    super.initState();
    checkAuthenticationAndLoadData();
  }

  // Checks if the user is authenticated.
  // If not, redirects to the sign-in page.
  // If authenticated, loads the feed data.
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
      // Handles errors such as network issues or unexpected failures.
      print("Error in checkAuthenticationAndLoadData: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Fetches feed data from the backend using the engine's getFeed method.
  // Updates the state with the fetched posts and stops the loading spinner.
  Future<void> getData() async {
    final result = await Controller().engine.getFeed(page: 1);
    print("length: ${result["posts"].length}");

    // Prevents setState if the widget has been disposed.
    if (!mounted) return;

    setState(() {
      data = result["posts"];
      isLoading = false;
    });
    print(data);
  }

  // Builds the UI for the feed page.
  // - Shows a loading spinner while fetching data.
  // - Displays the feed using FeedWidget when data is loaded.
  // - Always shows the navigation bar at the bottom.
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
          // Persistent navigation bar at the bottom of the screen.
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
