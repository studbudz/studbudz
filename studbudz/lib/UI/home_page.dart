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
    // Allows widgets to be placed above one another.
    return const Stack(
      children: [
        MapWidget(),
        //search bar
        Positioned(
          top: 70,
          left: 20,
          right: 20,
          child: RoundedSearchBox(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: NavBarWidget(height: 60),
        ),
      ],
    );
  }
}

//search for locations
//search for people
//search for events
class RoundedSearchBox extends StatelessWidget {
  const RoundedSearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Background color
        borderRadius: BorderRadius.circular(30), // Rounded border
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search...",
          border: InputBorder.none, // Removes default underline
        ),
      ),
    );
  }
}
