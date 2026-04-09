import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import 'heatmap_overlay.dart';
import 'map_filters.dart';

class CoverageMapView extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double zoom;
  final List<WeightedLatLng> heatData;
  final bool markersAlwaysVisible;
  final ColorScheme colorScheme;

  const CoverageMapView({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.zoom,
    required this.heatData,
    required this.markersAlwaysVisible,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: zoom,

      ),
      children: [
        ColorFiltered(
          colorFilter:  MapFilters.colorFilterForTheme(
            Theme.of(context).brightness,
          ),
          child: TileLayer(
            urlTemplate: isDark
                ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            retinaMode: true,
          ),
        ),
        HeatmapOverlay(
          heatData: heatData,
          zoom: zoom,
          markersAlwaysVisible: markersAlwaysVisible,
          colorScheme: colorScheme,
        ),
        MarkerLayer(
            markers: [
              userLocationMarker(initialCenter, colorScheme.primary, colorScheme.onPrimary),
            ]
        ),
      ],
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