import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'coverage_request_map_view.dart';
import 'simple_map_controller.dart';
import 'fullscreen_request_map_page.dart';

class CoverageRequestMap extends StatefulWidget {
  final List<LatLng> polygonPoints;

  const CoverageRequestMap({
    super.key,
    required this.polygonPoints,
  });

  @override
  State<CoverageRequestMap> createState() => _CoverageRequestMapState();
}

class _CoverageRequestMapState extends State<CoverageRequestMap> {
  final MapController _mapController = MapController();

  late final LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = widget.polygonPoints.first;
  }

  void _reset() {
    _mapController.move(_center, 14);
  }

  void _openFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenRequestMapPage(
          polygonPoints: widget.polygonPoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CoverageRequestMapView(
            mapController: _mapController,
            polygonPoints: widget.polygonPoints,
            initialCenter: _center,
          ),
        ),

        SimpleMapController(
          isFullScreen: false,
          colorScheme: colorScheme,
          onFullscreen: _openFullscreen,
          onReset: _reset,
        ),
      ],
    );
  }
}
