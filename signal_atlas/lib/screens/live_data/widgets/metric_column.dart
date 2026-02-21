import 'package:flutter/material.dart';
import 'signal_bars.dart';

class MetricColumn extends StatelessWidget {
  final String title;
  final int strength;
  final double value;
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
                    Text(getText(strength),
                      style: TextStyle(
                        color: getColor(strength, colorScheme),
                        fontSize: 20,
                      ),
                    ),
                    // Signal Bar
                    SignalBars (
                      strength: strength,
                      color: getColor(strength, colorScheme),
                    )
                  ],
                ),
                Text("$value $units",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ]
          ),
        ]
    );
  }

  Color getColor(int strength, ColorScheme scheme) {
    if (strength <= 1) return Colors.red;
    if (strength == 2) return Colors.orange;
    if (strength == 3) return Colors.lightGreen;
    return scheme.primary;
  }
  String getText(int strength) {
    if (strength <= 0) return "No Signal";
    if (strength == 1) return "Poor";
    if (strength == 2) return "Fair";
    if (strength == 3) return "Good";
    return "Excellent";
  } // not sure what to write
}
