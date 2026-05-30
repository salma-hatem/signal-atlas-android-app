import 'package:flutter/material.dart';

class StyledFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  final bool showCheckmark;

  const StyledFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,

      selectedColor: colorScheme.primary.withAlpha(30),
      backgroundColor: colorScheme.surface,

      showCheckmark: showCheckmark,
      checkmarkColor: colorScheme.primary,

      side: BorderSide(
        color: selected
            ? colorScheme.primary
            : colorScheme.outline.withAlpha(50),
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      labelStyle: TextStyle(
        color: selected
            ? colorScheme.primary
            : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
