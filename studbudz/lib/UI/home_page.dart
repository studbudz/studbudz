import 'package:flutter/material.dart';
import 'package:studubdz/UI/map_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;

  void _toggleSearch(bool isActive) {
    setState(() {
      _isSearching = isActive;
    });
  }

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
          child: NavBarWidget(),
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
    return Material(
      color: Colors.transparent, // Make the Material widget transparent
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the search box itself
          borderRadius: BorderRadius.circular(30), // Rounded border
        ),
        child: TextField(
          onChanged: (text) {
            Controller().engine.autoSuggest(text);
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.search),
            hintText: "Search...",
            border: InputBorder.none, // Removes default underline
          ),
        ),
      ),
    );
  }
}

class SearchOverlay extends StatefulWidget {
  final Function(bool) onFocusChange;

  const SearchOverlay({super.key, required this.onFocusChange});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: const Placeholder(),
      ),
    );
  }
}

//default layout
//Find on Map
//quick Add
//locations
//events

class DefaultLayout extends StatelessWidget {
  const DefaultLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [FindOnMap(), QuickAdd(), FindLocations()],
    );
  }
}

class FindOnMap extends StatelessWidget {
  const FindOnMap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class QuickAdd extends StatelessWidget {
  const QuickAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class FindLocations extends StatelessWidget {
  const FindLocations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
