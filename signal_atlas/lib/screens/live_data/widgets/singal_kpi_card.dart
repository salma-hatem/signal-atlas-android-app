import 'package:flutter/material.dart';
import 'package:signal_atlas/widgets/shimmer_box.dart';
import 'package:signal_atlas/utilities/theme/app_colors.dart';

class SignalKPICard extends StatelessWidget {
  final String title;
  final int? value;
  final String unit;
  final int rangeMin;
  final int rangeMax;

  const SignalKPICard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.rangeMin,
    required this.rangeMax,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalValue = value?? 0;
    double normalizedValue = 0;
    if (finalValue >= rangeMin && finalValue <= rangeMax) {
      normalizedValue = ((finalValue - rangeMin) / (rangeMax - rangeMin)).clamp(0.0, 1.0);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold,)),
            value == null
                ?shimmerBox(context, height: 12, width: 20)
                : Text("$value $unit", style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$rangeMin",
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: normalizedValue,
                  backgroundColor: colorScheme.outline.withAlpha(100),
                  color: AppColors.normalizedProgress(normalizedValue, colorScheme),
                ),
              ),
            ),
            const SizedBox(width: 4),

            Text(
              "$rangeMax",
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
          ],
        ),
      ],
    );
  }
  Color getColor(double normalizedValue, ColorScheme scheme) {
    if (normalizedValue <= 0.25) {
      return Colors.red;
    } else
    if (normalizedValue <= 0.5) {
      return Colors.orange;
    } else
    if (normalizedValue <= 0.75) {
      return Colors.lightGreen;
    } else {
      return scheme.primary;
    }
  }
}