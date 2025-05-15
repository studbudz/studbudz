import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/schedule_widget.dart'; // your new widget

// A stateless widget that displays the user's event schedule in a carousel or list view.
// Integrates with the backend to fetch upcoming events and provides navigation to other app sections.
//
// Features:
// - Displays a schedule of events using the [ScheduleWidget].
// - Persistent bottom navigation bar for seamless app navigation.
//
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  // Builds the schedule page UI.
  // - Uses a Stack to layer the schedule widget and the navigation bar.
  // - The [ScheduleWidget] displays event cards or a carousel.
  // - The [NavBarWidget] is positioned at the bottom for navigation.
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        ScheduleWidget(height: 0.5),
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
