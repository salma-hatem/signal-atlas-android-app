import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tabs = [
      {'icon': Icons.wifi_tethering, 'label': 'Live Data'},
      {'icon': Icons.analytics_outlined, 'label': 'Dashboard'},
      {'icon': Icons.storage, 'label': 'Data Hub'},
      {'icon': Icons.request_page_outlined, 'label': 'Requests'},
    ];

    return Material(
      color: colorScheme.surface,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = currentIndex == index;

            return InkWell(
              onTap: () => onTap(index),
              splashColor: colorScheme.secondary.withAlpha(30),
              highlightColor: colorScheme.secondary.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 28,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}