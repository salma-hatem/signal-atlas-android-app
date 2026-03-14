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
    super.key,
    required this.heatData,
    required this.zoom,
    required this.markersAlwaysVisible,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    print("Heatmap $heatData");
    if (heatData.isEmpty) return const SizedBox.shrink();

    final gradient = AppColors.heatmapGradient(colorScheme);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedHeatData = [...heatData]..sort((a, b) => (a.intensity ?? 0).compareTo(b.intensity ?? 0));
    final markerSize = markerSizeFromZoom(zoom);
    return Stack(
      children: [
        Opacity(
          opacity: (zoom < 18) ? 1.0 : ((zoom >= 19) ? 0.0 : (19 - zoom) / 2),
          child: Opacity(
            opacity: isDark ? 0.55 : 0.35,
            child: MarkerLayer(
              markers: sortedHeatData.map((point) {
                final value = point.intensity ?? 0;

                final color = gradient.entries
                    .lastWhere(
                      (e) => value >= e.key,
                  orElse: () => gradient.entries.first,
                )
                    .value;

                return Marker(
                  width: markerSize,
                  height: markerSize,
                  point: point.latLng,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withAlpha(200),
                          color.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
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

  double markerSizeFromZoom(double zoom) {
    const minZoom = 16.0;
    const maxZoom = 20.0;

    const minSize = 20.0;
    const maxSize = 80.0;

    // normalize zoom to 0..1
    double t = ((zoom - minZoom) / (maxZoom - minZoom)).clamp(0.0, 1.0);

    // smooth curve (easeOut)
    t = 1 - (1 - t) * (1 - t);

    return minSize + (maxSize - minSize) * t;
  }
}