import 'package:flutter/material.dart';

class WidgetTooltip extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const WidgetTooltip({
    required this.child,
    required this.tooltip,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 200),
      showDuration: const Duration(seconds: 2),
      verticalOffset: 30,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withAlpha(100),
          width: 0.2,
        ),
      ),
      textStyle: TextStyle(
        color: textColor ?? colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
      child: child,
    );
  }
}
