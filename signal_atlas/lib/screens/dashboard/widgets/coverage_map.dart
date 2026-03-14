import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '/models/network_reading.dart';
import 'map_button.dart';
import 'heatmap_overlay.dart';
import 'map_filters.dart';

class CoverageMap extends StatefulWidget {
  final NetworkReading initialReading;
  final List<WeightedLatLng> heatData;

  const CoverageMap({
    super.key,
    required this.initialReading,
    required this.heatData,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ------------------------------------------------
        // Map
        // ------------------------------------------------
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 16,
            onMapEvent: (event) {
              setState(() {
                _zoom = _mapController.camera.zoom;
              });
            },
          ),
          children: [
            ColorFiltered(
              colorFilter: MapFilters.colorFilterForTheme(Theme.of(context).brightness),
              child: TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
              ),
            ),
            HeatmapOverlay(
              heatData: widget.heatData,
              zoom: _zoom,
              markersAlwaysVisible: _markersAlwaysVisible,
              colorScheme: colorScheme,
            ),
            MarkerLayer(
              markers: [
                userLocationMarker(_initialCenter, colorScheme.primary, colorScheme.onPrimary),
              ]
            ),
          ],
        ),
        // ------------------------------------------------
        // Reset Location Button
        // ------------------------------------------------
        Positioned(
          top: 8,
          right: 8,
          child: buildMapButton(
            icon: Icons.gps_fixed,
            tooltip: "Reset location",
            onPressed: () => _mapController.moveAndRotate(_initialCenter, 16,0),
            colorScheme: colorScheme,
          ),
        ),
        // ------------------------------------------------
        // Toggle Markers Button
        // ------------------------------------------------
        Positioned(
          top: 56,
          right: 8,
          child: buildMapButton(
            icon: _markersAlwaysVisible ? Icons.pin_drop_rounded : Icons.pin_drop_outlined,
            tooltip: "Toggle markers",
            onPressed: () => {
              setState(() {
              _markersAlwaysVisible = !_markersAlwaysVisible;
              })
            },
            colorScheme: colorScheme,
          ),
        ),
      ]
    );
  }

  Marker userLocationMarker(LatLng position, Color color, Color borderColor) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      alignment: Alignment.bottomCenter,
      child: Builder(
        builder: (context) {
          final rotation = MapCamera.of(context).rotationRad;

          return Transform.rotate(
            angle: -rotation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  size: 40,
                  color: borderColor,
                ),
                Icon(
                  Icons.location_pin,
                  size: 32,
                  color: color,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
