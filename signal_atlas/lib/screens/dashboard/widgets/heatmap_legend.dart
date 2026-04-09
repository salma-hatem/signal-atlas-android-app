import 'package:flutter/material.dart';
import '/utilities/theme/app_colors.dart';

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientMap = AppColors.heatmapGradient(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          // Gradient bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientMap.values.map((c) => c.shade500).toList(),
                  stops: gradientMap.keys.toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Low", style: TextStyle(fontSize: 12)),
              Text("High", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}