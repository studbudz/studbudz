import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studubdz/notifier.dart';

// A customizable bottom navigation bar for the application.
//
// Features:
// - Navigates between Feed, Home, Schedule, and Profile pages.
// - Home icon toggles to "Add Post" when on the Home page.
// - Highlights the active page with a blue color.
// - Uses Cupertino and Material icons for a modern look.
//
// Parameters:
//   - height: double (optional). The bottom padding of the navigation bar. Default is 60.
class NavBarWidget extends StatefulWidget {
  final double height;
  const NavBarWidget({super.key, this.height = 60});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

// State for NavBarWidget
//
// Handles the selected navigation index and updates the current page.
// Maintains icon highlighting and toggling between Home and Add Post.
class _NavBarWidgetState extends State<NavBarWidget> {
  int selectedIndex = 0;
  AppPage currentPage = Controller().currentPage;
  double iconSize = 36; // Standard icon size for nav bar

  // List of icons for navigation tabs

  final List<IconData> icons = [
    CupertinoIcons.square_stack_3d_up, // Feed
    CupertinoIcons.home, // Home (center icon)
    CupertinoIcons.calendar, // Schedule
    CupertinoIcons.person, // Profile
    CupertinoIcons.add // Add (not used directly)
  ];

  final List<String> labels = [
    'Feed',
    'Home',
    'Schedule',
    'Profile',
    'Add Post',
  ];

  // Builds the navigation bar UI.
  // - Uses a Row of IconButtons for navigation.
  // - Highlights the selected icon.
  // - Handles Home/Add Post toggle logic.
  @override
  Widget build(BuildContext context) {
    Controller notifier = Controller();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.height),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Feed
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                  notifier.setPage(AppPage.feed);
                },
                icon: Icon(
                  icons[0],
                  size: iconSize,
                  color:
                      currentPage == AppPage.feed ? Colors.blue : Colors.black,
                ),
              ),
              // Home (with toggle to Add Post)
              IconButton(
                onPressed: () {
                  if (currentPage == AppPage.home) {
                    notifier.setPage(AppPage.createPost);
                  } else {
                    setState(() {
                      selectedIndex = 1;
                    });
                    print('Tapped on ${labels[1]}');
                    notifier.setPage(AppPage.home);
                  }
                },
                icon: Icon(
                  currentPage == AppPage.home ? CupertinoIcons.add : icons[1],
                  size: iconSize,
                  color:
                      currentPage == AppPage.home ? Colors.blue : Colors.black,
                ),
              ),
              // Schedule
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                  print('Tapped on ${labels[2]}');
                  notifier.setPage(AppPage.schedule);
                },
                icon: Icon(
                  icons[2],
                  size: iconSize,
                  color: currentPage == AppPage.schedule
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
              // Profile
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 3;
                  });
                  print('Tapped on ${labels[3]}');
                  notifier.setPage(AppPage.profile);
                },
                icon: Icon(
                  icons[3],
                  size: iconSize,
                  color: currentPage == AppPage.profile
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
