import 'package:flutter/material.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final int? value;
  final String units;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              value == null
                  ?shimmerBox(context, height: 24, width: 40)
                  : Text(
                  "$value",
                  style: Theme.of(context).textTheme.titleLarge
                ),
              const SizedBox(width: 4),
              Text(
                units,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}