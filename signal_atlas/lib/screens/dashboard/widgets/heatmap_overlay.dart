import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

import '/utilities/theme/app_colors.dart';

class HeatmapOverlay extends StatelessWidget {
  final List<WeightedLatLng> heatData;
  final double zoom;
  final bool markersAlwaysVisible;
  final ColorScheme colorScheme;

  const HeatmapOverlay({
    required this.heatData,
    required this.zoom,
    required this.markersAlwaysVisible,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (heatData.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Opacity(
          opacity: (zoom < 18) ? 1.0 : ((zoom >= 19) ? 0.0 : (19 - zoom) / 2),
          child: HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: heatData),
            heatMapOptions: HeatMapOptions(
              radius: 40,
              minOpacity: isDark ? 0.85 : 0.65,
              gradient: AppColors.heatmapGradient(colorScheme),
            ),
          ),
        ),
        Opacity(
          opacity: markersAlwaysVisible
              ? 1.0
              : (zoom < 18)
              ? 0.0
              : ((zoom >= 20) ? 1.0 : (zoom - 18) / 2),
          child: MarkerLayer(
            markers: heatData.map((point) {
              final value = point.intensity ?? 0;
              final color = AppColors.heatmapGradient(colorScheme)
                  .entries
                  .lastWhere((e) => value >= e.key)
                  .value;
              return Marker(
                width: 12,
                height: 12,
                point: point.latLng,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}