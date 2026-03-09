import 'package:flutter/material.dart';
import '/widgets/widget_tooltip.dart';

Widget buildMapButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
  required ColorScheme colorScheme,
}) {
  return WidgetTooltip(
    tooltip: tooltip,
    child: IconButton.filled(
      icon: Icon(icon),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.all(6),
      ),
    ),
  );
}