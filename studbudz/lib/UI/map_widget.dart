import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// A stateful widget that displays an interactive map using flutter_map.
//
// Features:
// - Supports multiple map tile styles (default, light, dark)
// - Uses OpenStreetMap and Stadia Maps tile providers
// - Configurable through MapController
//
// Parameters:
//   - key: Widget key for identification
//
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _HomePageState();
}

//credit based (please don't abuse...)
// const apiKey = 'c8e66e68-0bd9-4ec0-9207-11212ce675d6';
// Map tile configuration constants
const apiKey = ''; // Required for Stadia Maps (keep empty for OpenStreetMap)

// Supported map styles with their respective tile URLs
// - default: Standard OpenStreetMap tiles
// - light: Light-themed Stadia Maps tiles
// - dark: Dark-themed Stadia Maps tiles
final maps = {
  'default': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  'light':
      'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png',
  'dark':
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
};

class _HomePageState extends State<MapWidget> {
  late MapController _mapController;
  // Initializes the map controller when the widget is created
  //
  // The MapController should be initialized here rather than in build()
  // to maintain proper lifecycle management

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Controller for map interactions/updates
  }
  // Builds the map interface with selected tile layer
  //
  // Returns a FlutterMap widget with:
  // - Configurable tile layer
  // - Map controller for programmatic control
  // - Default map options

  @override
  Widget build(BuildContext context) {
    final styleUrl = maps['default'];
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: "$styleUrl?api_key={api_key}",
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          additionalOptions: const {
            'api_key': apiKey,
          },
        ),
      ],
    );
  }
}
