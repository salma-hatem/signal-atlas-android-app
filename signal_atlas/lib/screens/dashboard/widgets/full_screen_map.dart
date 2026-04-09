import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import 'coverage_map_view.dart';
import 'map_overlay_controls.dart';

class FullscreenMapPage extends StatefulWidget {
  final LatLng initialCenter;
  final List<WeightedLatLng> heatData;

  const FullscreenMapPage({
    super.key,
    required this.initialCenter,
    required this.heatData,
  });

  @override
  State<FullscreenMapPage> createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<FullscreenMapPage> {
  final MapController _mapController = MapController();
  bool _markersAlwaysVisible = false;
  double _zoom = 16;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ------------------------------------------------
          // Map
          // ------------------------------------------------
          CoverageMapView(
            mapController: _mapController,
            initialCenter: widget.initialCenter,
            zoom: _zoom,
            heatData: widget.heatData,
            markersAlwaysVisible: _markersAlwaysVisible,
            colorScheme: colorScheme,
          ),

          // ------------------------------------------------
          // Map Controls (Buttons)
          // ------------------------------------------------
          MapOverlayControls(
            isFullScreen: true,
            colorScheme: colorScheme,
            markersAlwaysVisible: _markersAlwaysVisible,
            onBack: _closeFullscreen,
            onReset: _reset,
            onToggleMarkers: _toggleMarkers
          ),

        ],
      ),
    );
  }
  // ------------------------------------------------
  // Buttons Functions
  // ------------------------------------------------
  void _toggleMarkers() {
    setState(() {
      _markersAlwaysVisible = !_markersAlwaysVisible;
    });
  }

  void _reset() {
    _mapController.moveAndRotate(widget.initialCenter, 16, 0);
  }

  void _closeFullscreen() {
    Navigator.pop(context);
  }
}