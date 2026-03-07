import 'package:flutter/material.dart';
import 'signal_bars.dart';
import 'package:signal_atlas/utilities/theme/app_colors.dart';
import 'package:signal_atlas/utilities/signal_thresholds.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';

class MetricColumn extends StatelessWidget {
  final String title;
  final int? strength;
  final double? value;
  final String units;

  const MetricColumn({
    super.key,
    required this.title,
    required this.strength,
    required this.value,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int strengthValue = strength?? 0;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold,)
          ),

          const SizedBox(height: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(SignalThresholds.label(strengthValue),
                      style: TextStyle(
                        color: AppColors.strengthColor(strengthValue, colorScheme),
                        fontSize: 20,
                      ),
                    ),
                    // Signal Bar
                    SignalBars (
                      strength: strengthValue,
                      color: AppColors.strengthColor(strengthValue, colorScheme),
                    )
                  ],
                ),
                value == null
                  ?shimmerBox(context, height: 12, width: 40)
                  : Text("$value $units",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
              ]
          ),
        ]
    );
  }
}
