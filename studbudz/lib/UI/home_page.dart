import 'package:flutter/material.dart';
import 'package:studubdz/UI/map_widget.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/notifier.dart';

// The main landing page of the application.
//
// - Displays an interactive map, a search bar for locations/people/events, and a bottom navigation bar.
// - Uses a Stack to layer UI elements.
// - Designed to be easily extensible with overlays and quick actions.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tracks if the search overlay is active (not currently used, but ready for future overlays)
  bool _isSearching = false;

  // Toggles the search overlay state.
  // Can be used to show/hide advanced search overlays in the future.
  void _toggleSearch(bool isActive) {
    setState(() {
      _isSearching = isActive;
    });
  }

  // Builds the main UI for the home page.
  // - Uses a Stack to layer the map, search bar, and navigation bar.
  // - All children are const for performance; dynamic overlays can be added in the future.
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
// - Calls Controller().engine.autoSuggest(text) on input change.
// - Designed for placement over the map with a modern, rounded look.
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

// A full-screen overlay for displaying search results or advanced search UI.
//
// Parameters:
//   - onFocusChange: Callback for when the overlay gains or loses focus.
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
// A column of quick-access widgets for actions like finding on map or adding locations/events.
//
// Currently contains placeholders for future implementation.
class DefaultLayout extends StatelessWidget {
  const DefaultLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [FindOnMap(), QuickAdd(), FindLocations()],
    );
  }
}

// Placeholder widget for a "Find on Map" quick action.
class FindOnMap extends StatelessWidget {
  const FindOnMap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//
// Placeholder widget for a "Quick Add" action (e.g., add a new location or event).
class QuickAdd extends StatelessWidget {
  const QuickAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// Placeholder widget for a "Find Locations" quick action.
class FindLocations extends StatelessWidget {
  const FindLocations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
