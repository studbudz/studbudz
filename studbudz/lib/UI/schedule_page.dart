import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/schedule_widget.dart'; // your new widget

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

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
