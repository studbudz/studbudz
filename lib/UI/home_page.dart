import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//api key:  c8e66e68-0bd9-4ec0-9207-11212ce675d6

const apiKey = 'c8e66e68-0bd9-4ec0-9207-11212ce675d6';

final maps = {
  'default': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  'light':
      'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png',
  'dark':
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
};

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final styleUrl = maps['dark'];
    return FlutterMap(
      mapController: MapController(),
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: "$styleUrl?api_key={api_key}",
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          additionalOptions: const {
            'api_key': apiKey,
          },
          // Plenty of other options available!
        ),
      ],
    );
  }
}
