import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'coverage_request_map_view.dart';
import 'simple_map_controller.dart';

class FullscreenRequestMapPage extends StatefulWidget {
  final List<LatLng> polygonPoints;

  const FullscreenRequestMapPage({
    super.key,
    required this.polygonPoints,
  });

  @override
  State<FullscreenRequestMapPage> createState() => _FullscreenRequestMapPageState();
}

class _FullscreenRequestMapPageState extends State<FullscreenRequestMapPage> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          CoverageRequestMapView(
            mapController: _mapController,
            polygonPoints: widget.polygonPoints,
            initialCenter: _center,
          ),

          SimpleMapController(
            isFullScreen: true,
            colorScheme: colorScheme,

            onBack: () => Navigator.pop(context),

            onReset: _reset,
          ),
        ],
      ),
    );
  }
}
