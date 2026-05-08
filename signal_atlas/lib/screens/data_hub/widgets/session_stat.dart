import 'package:flutter/material.dart';
import 'package:signal_atlas/widgets/widget_tooltip.dart';

class SessionStat extends StatelessWidget {
  final String tooltip;
  final String title;
  final String value;
  final Widget? textWidget;
  final ColorScheme colorScheme;

  const SessionStat({
    super.key,
    required this.title,
    required this.tooltip,
    required this.value,
    this.textWidget,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return
      Expanded(
        child: WidgetTooltip(
          tooltip: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textWidget ?? Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
