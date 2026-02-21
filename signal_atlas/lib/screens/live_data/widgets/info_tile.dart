import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;

  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          // border: Border(
          //   left: BorderSide(
          //     color: colorScheme.secondary,
          //     width: 2,
          //   ),
          // )

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}