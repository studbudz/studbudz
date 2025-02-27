import 'package:flutter/material.dart';
import 'package:studubdz/UI/map_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        //search bar
        MapWidget(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: NavBarWidget(height: 10),
        ),
      ],
    );
  }
}
