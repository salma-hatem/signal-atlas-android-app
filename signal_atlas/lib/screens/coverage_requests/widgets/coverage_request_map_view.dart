import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../utilities/map_filters.dart';

class CoverageRequestMapView extends StatelessWidget {
  final MapController mapController;
  final List<LatLng> polygonPoints;
  final LatLng initialCenter;

  const CoverageRequestMapView({
    super.key,
    required this.mapController,
    required this.polygonPoints,
    required this.initialCenter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return FlutterMap(
      mapController: mapController,

      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 14,
      ),

      children: [
        ColorFiltered(
          colorFilter: MapFilters.colorFilterForTheme(
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

        PolygonLayer(
          polygons: [
            Polygon(
              points: polygonPoints,
              color: colorScheme.primary.withAlpha(50),
              borderColor: colorScheme.primary,
              borderStrokeWidth: 3,
            ),
          ],
        ),
      ],
    );
  }
}
