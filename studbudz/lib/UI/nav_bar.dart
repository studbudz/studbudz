import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studubdz/notifier.dart';

class NavBarWidget extends StatefulWidget {
  final double height;
  const NavBarWidget({super.key, this.height = 60});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int selectedIndex = 0;
  AppPage currentPage = Controller().currentPage;
  double iconSize = 36;

  final List<IconData> icons = [
    CupertinoIcons.square_stack_3d_up,
    CupertinoIcons.home,
    CupertinoIcons.calendar,
    CupertinoIcons.chat_bubble_text,
    CupertinoIcons.person,
    CupertinoIcons.add
  ];

  final List<String> labels = [
    'Feed',
    'Home',
    'Schedule',
    // 'Chat',
    'Profile'
        'Add Post',
  ];

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
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                  notifier.setPage(AppPage.feed); // Navigate to Feed
                },
                icon: Icon(
                  icons[0],
                  size: iconSize,
                  color:
                      currentPage == AppPage.feed ? Colors.blue : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                    print('Tapped on ${labels[2]}');
                    notifier.setPage(AppPage.schedule);
                  });
                },
                icon: Icon(
                  icons[2],
                  size: iconSize,
                  color: currentPage == AppPage.schedule
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (currentPage == AppPage.home) {
                    notifier.setPage(AppPage.createPost);
                  } else {
                    setState(() {
                      selectedIndex = 2;
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
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 4;
                  });
                  print('Tapped on ${labels[4]}');
                  notifier.setPage(AppPage.chat);
                },
                icon: Icon(
                  icons[4],
                  size: iconSize,
                  color: currentPage == AppPage.profile
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
              //               IconButton(
              //   onPressed: () {
              //     setState(() {
              //       selectedIndex = 3;
              //     });
              //     print('Tapped on ${labels[3]}');
              //     notifier.setPage(AppPage.chat); // Navigate to FeedPage
              //   },
              //   icon: Icon(
              //     icons[3],
              //     size: iconSize,
              //     color:
              //         currentPage == AppPage.chat ? Colors.blue : Colors.black,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
