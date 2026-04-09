import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '/models/network_reading.dart';
import 'coverage_map_view.dart';
import 'map_overlay_controls.dart';
import 'full_screen_map.dart';

class CoverageMap extends StatefulWidget {
  final NetworkReading initialReading;
  final List<WeightedLatLng> heatData;
  final VoidCallback enableMap;
  final bool enabled;

  const CoverageMap({
    super.key,
    required this.initialReading,
    required this.heatData,
    required this.enabled,
    required this.enableMap,
  });

  @override
  State<CoverageMap> createState() => _CoverageMapState();
}

class _CoverageMapState extends State<CoverageMap> {
  final MapController _mapController = MapController();
  late final LatLng _initialCenter;
  bool _markersAlwaysVisible = false;

  @override
  void initState() {
    super.initState();

    _initialCenter = LatLng(
      widget.initialReading.latitude,
      widget.initialReading.longitude,
    );
  }
  double _zoom = 16;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // ------------------------------------------------
        // Map
        // ------------------------------------------------
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.enableMap,
          child: IgnorePointer(
            ignoring: !widget.enabled,
              child: CoverageMapView(
                mapController: _mapController,
                initialCenter: _initialCenter,
                zoom: _zoom,
                heatData: widget.heatData,
                markersAlwaysVisible: _markersAlwaysVisible,
                colorScheme: colorScheme,
              ),
            ),
          ),

        // ------------------------------------------------
        // Map Controls (Buttons)
        // ------------------------------------------------
        MapOverlayControls(
          colorScheme: colorScheme,
          markersAlwaysVisible: _markersAlwaysVisible,
          onFullscreen: _openFullscreen,
          onReset: _reset,
          onToggleMarkers: _toggleMarkers,
        ),
      ],
    );
  }

  // ------------------------------------------------
  // Buttons Functions
  // ------------------------------------------------
  void _toggleMarkers() {
    widget.enableMap();
    setState(() {
      _markersAlwaysVisible = !_markersAlwaysVisible;
    });
  }

  void _reset() {
    widget.enableMap();
    _mapController.moveAndRotate(_initialCenter, 16, 0);
  }

  void _openFullscreen() {
    widget.enableMap();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenMapPage(
          initialCenter: _initialCenter,
          heatData: widget.heatData,
        ),
      ),
    );
  }

}
