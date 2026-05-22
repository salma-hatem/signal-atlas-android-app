import 'package:flutter/material.dart';
import '/widgets/widget_tooltip.dart';

Widget buildMapButton({
  required IconData icon,
  required double size,
  required double iconPadding,
  required String tooltip,
  required VoidCallback onPressed,
  required ColorScheme colorScheme,
}) {
  return WidgetTooltip(
    tooltip: tooltip,
    child: IconButton.filled(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        padding: EdgeInsets.all(iconPadding),
        side: BorderSide(
          color: colorScheme.secondary.withAlpha(150)
        )
      ),
    ),
  );
}